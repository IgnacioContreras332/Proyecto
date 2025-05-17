#include <WiFi.h>
#include <WiFiClient.h>
#include "ESP32Servo.h"

Servo miServo;
Servo miServo2;
WiFiClient cliente;

// Datos de la conexión a internet
const char* ssid = "ZAC-BC_PC";
const char* password = "123456789";

// Datos de la conexión al servidor
const char* server_ip = "192.168.137.70";
const int server_port = 65440;

// Puertos del ESP32
const int PuertoTemperatura = 33;
const int PuertoHumedad = 32;
const int PuertoPH = 35;

// LED Indicador
const int ledPin = 2;

// Puertos Servos
const int Servo_principal = 13;
const int Servo_secundario = 12;

// Puerto Ultrasonico
const int trigPin = 5;
const int echoPin = 4;

// Variables de almacenamiento
int temperatura = 0;
int humedad = 0;
int ph = 0;
long duracion;
int distancia;

void setup() {
    
    // LED indicador
    pinMode(ledPin, OUTPUT);

    // Baudios de la comunicación serial
    Serial.begin(115200);

    //Configuracion Servos
    miServo2.attach(Servo_secundario);
    miServo2.write(0);
    miServo.attach(Servo_principal);
    miServo.write(90);

    // Configura los pines como salida (Trig) y entrada (Echo)
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);
    
    // Estableciendo conexión a la red
    Serial.println("Conectando a la red...");
    WiFi.begin(ssid, password);

    // Espera hasta que se conecte al WiFi
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    
    Serial.println("\nConexión establecida");
    Serial.print("Dirección IP: ");
    Serial.println(WiFi.localIP());
}

void loop() {
    
    // Limpia el pin Trig poniéndolo en LOW por un corto tiempo
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);

    // Leer valores de los sensores
    temperatura = analogRead(PuertoTemperatura);
    humedad = analogRead(PuertoHumedad);
    ph = analogRead(PuertoPH);

    // Envía un pulso de 10 microsegundos al pin Trig
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    
    // Mide la duración del pulso en el pin Echo
    duracion = pulseIn(echoPin, HIGH);
    // Calcula la distancia en centímetros (la velocidad del sonido es aproximadamente 343 m/s o 0.0343 cm/microsegundo)
    // Dividimos entre 2 porque el sonido viaja hasta el objeto y regresa
    distancia = duracion * 0.0343 / 2;

    // Normalización de valores (puedes ajustarlo según tu calibración)
    float temperaturaReal = (temperatura / 4095.0) * 100.0;
    float humedadReal = (humedad / 4095.0) * 100.0;
    float phReal = (ph / 4095.0) * 14.0;

    // Crear un mensaje JSON con los datos
    String mensaje = "{";
    mensaje += "\"nivel_comedero1\":\"" + String(temperaturaReal) + "\",";
    mensaje += "\"nivel_comedero2\":\"" + String(humedadReal) + "\",";
    mensaje += "\"nivel_comedero3\":\""+ String(distancia) + "\"";
    mensaje += "}";

    // Verificar conexión antes de enviar datos
    if (!cliente.connected()) {
        Serial.println("Conexión perdida, reconectando...");
        if (!cliente.connect(server_ip, server_port)) {
            Serial.println("No se pudo conectar al servidor");
            delay(5000);
            return;
        }
    }
    
    // Enviar el mensaje JSON a través de Bluetooth en cada ciclo
    Serial.println(mensaje);
    // Enviar el mensaje al servidor
    cliente.print(mensaje);

    // Pasar datos desde Bluetooth al monitor serial
    if (cliente.available()) {
        char Entrada = cliente.read(); // Declaración de la variable 'Entrada' como char
        cliente.write(Entrada);
        if (Entrada == 'H'){
            digitalWrite(ledPin, HIGH);
            miServo.write(0);
            miServo2.write(90);
        } else if(Entrada == 'L'){
            digitalWrite(ledPin, LOW);
            miServo.write(90);
            miServo2.write(0);
        }
    }
    if (Serial.available()) {
        cliente.write(Serial.read());
    }
    delay(1500);
    
//server_ip = "192.168.137.70";
//server_port = 65440;
    
}