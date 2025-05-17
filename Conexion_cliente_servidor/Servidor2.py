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
        self.clientes = []  # Lista para almacenar los clientes conectados

        self.iniciar_conexiones()

    def iniciar_conexiones(self):
        print(f"Escuchando en la dirección {self.DIRECCION}:{self.PUERTO}")

        while True:
            cliente_socket, cliente_direccion = self.servidor.accept()
            print(f"Cliente conectado: {cliente_direccion[0]}:{cliente_direccion[1]}")

            self.clientes.append(cliente_socket)

            # Si hay dos clientes conectados, iniciar la comunicación entre ellos
            if len(self.clientes) == 2:
                threading.Thread(target=self.reenviar_mensajes, args=(self.clientes[0], self.clientes[1])).start()
                threading.Thread(target=self.reenviar_mensajes, args=(self.clientes[1], self.clientes[0])).start()

    def reenviar_mensajes(self, origen_socket, destino_socket):
        while True:
            try:
                mensaje = origen_socket.recv(1024)

                if not mensaje:
                    print("Un cliente cerró la conexión")
                    break

                destino_socket.send(mensaje)

            except ConnectionResetError:
                print("El cliente cerró abruptamente la conexión")
                break
            except Exception as e:
                print(f"Error inesperado: {e}")
                break

        origen_socket.close()
        destino_socket.close()
        self.clientes.remove(origen_socket)
        self.clientes.remove(destino_socket)
        print("Conexión entre clientes cerrada")

def main():
    servidor = ServidorSocket()

if __name__ == "__main__":
    main()