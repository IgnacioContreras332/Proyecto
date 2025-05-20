import socket
import threading

class ServidorSocket:
    DIRECCION = "192.168.0.182"  # Cambia si es necesario
    PUERTO = 65440

    def __init__(self):
        print("Dentro del servidor")
        self.servidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.servidor.bind((self.DIRECCION, self.PUERTO))
        self.servidor.listen(2)  # Esperar hasta 2 conexiones (Flutter app y ESP32)
        self.clientes = []  # Lista para almacenar los clientes conectados

        self.iniciar_conexiones()

    def iniciar_conexiones(self):
        print(f"Escuchando en la dirección {self.DIRECCION}:{self.PUERTO}")

        while True:
            cliente_socket, cliente_direccion = self.servidor.accept()
            print(f"Cliente conectado: {cliente_direccion[0]}:{cliente_direccion[1]}")
            self.clientes.append(cliente_socket)

            if len(self.clientes) == 2:
                print("Dos clientes conectados. Iniciando comunicación bidireccional.")
                threading.Thread(target=self.manejar_cliente, args=(self.clientes[0], self.clientes[1])).start()
                threading.Thread(target=self.manejar_cliente, args=(self.clientes[1], self.clientes[0])).start()
                # Reiniciar la lista de clientes para la siguiente par de conexiones
                self.clientes = []

    def manejar_cliente(self, origen_socket, destino_socket):
        while True:
            try:
                mensaje = origen_socket.recv(1024)
                if not mensaje:
                    print(f"Cliente {origen_socket.getpeername()} cerró la conexión")
                    break
                print(f"Reenviando de {origen_socket.getpeername()} a {destino_socket.getpeername()}: {mensaje.decode('utf-8')}")
                destino_socket.send(mensaje)
            except ConnectionResetError:
                print(f"Cliente {origen_socket.getpeername()} cerró abruptamente la conexión")
                break
            except Exception as e:
                print(f"Error al manejar cliente {origen_socket.getpeername()}: {e}")
                break

        origen_socket.close()
        destino_socket.close()
        print(f"Conexión entre {origen_socket.getpeername()} y {destino_socket.getpeername()} cerrada")

def main():
    servidor = ServidorSocket()

if __name__ == "__main__":
    main()