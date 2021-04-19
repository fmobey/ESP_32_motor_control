#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
const int potpin = 36;
int potdeger = 0;
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;


#define SERVICE_UUID        "eb36d2c8-e3da-41f7-8120-2664c83fa432"
#define CHARACTERISTIC_UUID "433d109a-a336-4479-bfa5-7c29097d65ca"


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic){
    std::string value = pCharacteristic->getValue();

    if(value.length() > 0){

      Serial.println("**********");
      Serial.print("Yeni Değer: ");
      
      for(int i=0; i < value.length(); i++){
        Serial.print(value[i]);
      }

      Serial.println();
      Serial.println("**********");
      
    }
  }
};


void setup() {
  Serial.begin(115200);
 
  
  BLEDevice::init("Kutar bilisim");

  
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->setCallbacks(new MyCallbacks());


  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0); 
  BLEDevice::startAdvertising();
  Serial.println("Bir istemci bağlantısının bildirimde bulunması bekleniyor...");
}

void loop() {
    potdeger=analogRead(potpin);
    Serial.println(potdeger);
    delay(500);
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); 
        pServer->startAdvertising(); 
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }

    if (deviceConnected && !oldDeviceConnected) {
        
        oldDeviceConnected = deviceConnected;
    }
}
