import socket
import threading

class ServidorSocket:
    DIRECCION = "192.168.137.70"  # Cambia si es necesario
    PUERTO = 65440

    def __init__(self):
        print("Dentro del servidor")
        self.servidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.servidor.bind((self.DIRECCION, self.PUERTO))
        self.servidor.listen(5)  # Permitir múltiples conexiones

        # Se elimina el timeout para que el servidor espere indefinidamente
        self.servidor.settimeout(None)

        self.iniciar_conexiones()

    def iniciar_conexiones(self):
        print(f"Escuchando en la dirección {self.DIRECCION}:{self.PUERTO}")

        while True:
            cliente_socket, cliente_direccion = self.servidor.accept()
            tarea = threading.Thread(target=self.manejar_conexion, args=(cliente_socket, cliente_direccion))
            tarea.start()

    def manejar_conexion(self, cliente_socket, cliente_direccion):
        print(f"Aceptando conexión de: {cliente_direccion[0]}:{cliente_direccion[1]}")
        while True:
            try:
                request = cliente_socket.recv(1024)

                if not request:
                    print("Cliente ha cerrado la conexión")
                    break

                # request = request.decode("utf-8")
                # print(f"Recibido: {request}")
                # response = "Aceptada".encode("utf-8")
                
                cliente_socket.send(request)

            except ConnectionResetError:
                print("El cliente cerró abruptamente la conexión")
                break
            except Exception as e:
                print(f"Error inesperado: {e}")
                break

        cliente_socket.close()
        print("Conexión cerrada")

def main():
    servidor = ServidorSocket()

if __name__ == "__main__":
    main()