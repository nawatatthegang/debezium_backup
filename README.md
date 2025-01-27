# Debezium Backup

## Preparing for when Kafka Connect is gone

### ถ้า Debezium (i.e. server ที่รัน Kafka Connect) ระเบิด

- เก็บ config ที่ใช้ทั้งหมด (connector config ของ Kafka Connect) จะถูกเก็บไว้บน Kafka ตาม topic ที่เราตั้งไว้ตอน deploy
- ถ้า server เก่าระเบิดหายไปทั้งหมด ให้สร้าง server Kafka Connect ขึ้นมาใหม่แล้วตั้ง group id และชี้ config, status, offset topic ไปที่เดิมแล้วรัน
  - ถ้ารัน Kafka Connect ด้วย Docker ต้องใช้ env เดิม
    - `CONNECT_GROUP_ID`
    - `CONNECT_CONFIG_STORAGE_TOPIC`
    - `CONNECT_OFFSET_STORAGE_TOPIC`
    - `CONNECT_STATUS_STORAGE_TOPIC`
- ถ้าแค่ container ล่ม สามารถสั่ง `docker run` ใหม่ได้เลย ที่เหลือ Kafka Connect จะไปดึง config มาจาก topic ใน Kafka เอง

สิ่งที่ต้องเก็บ: Dockerfile ที่ใช้สร้าง Kafka Connect ที่มี connector plugin ที่ต้องใช้กับ env ข้างบน

### Kafka Connect ล่ม server ยังอยู่ แต่ replication slot โดนลบไปตอนล่ม

- โดนลบตอน Debezium เกาะอยู่ไม่ได้ จะเจอ error ว่ามี PID ใช้งานอยู่
- ถ้า Kafka Connect ล่มแล้ว replication slot โดนลบระหว่างล่ม change ระหว่างเวลาที่ล่มไปจะหายหมด
  - วิธีการ recover คือ ต้องลบ topic ใน Kafka ที่ออกมาจาก Debezium แล้วเริ่มใหม่จาก initial snapshot ของ database

สิ่งที่ต้องเก็บ: connector config ของ Debezium

### ถ้า Postgres ล่มแต่ replication slot ไม่บึ้ม

- ถ้าล่มไม่นาน Debezium จะพยายามต่อ database ซ้ำๆ จนมันกลับมา
- ถ้าล่มนาน Debezium connector ใน Kafka Connect จะ fail แต่ Kafka Connect container จะไม่ล่ม
  - recovery คือต้อง manual restart connector (ยิง curl command เข้าไป)
- สามารถ monitor status ได้ใน status topic ของ Kafka Connect (ตาม config ตอน deploy) หรือยิง curl command เพื่อเช็ค status ของ Debezium connector ได้

สิ่งที่ต้องเก็บ: ไม่มี

## Preparing for when Kafka Cluster is gone

### Poor ver.

- ถอด Debezium connector ออกจาก Kafka Connect และลบ publication/replication slot บน Postgres
- สร้าง Kafka cluster ใหม่ ต่อ Kafka Connect เข้า cluster ใหม่ให้มัน snapshot db ตั้งแต่ต้นอีกรอบแล้วรันทุกอย่างต่อจากเดิม

### Rich ver.

- ตั้ง Kafka cluster ไว้ 2 ชุดแล้วใช้ [Confluent Replicator](https://www.confluent.io/hub/confluentinc/kafka-connect-replicator) replicate ข้อมูลของทุก topic ระหว่างทั้ง 2 cluster
- ลาก devops มา restart หรือสร้าง Kafka cluster ขึ้นมาใหม่อีกรอบแล้ว populate อันใหม่จาก replicated Kafka
- ต่อ Debezium และ connector อื่นๆ ใน Kafka Connect กลับเข้าไปที่ active cluster

---

สุดท้ายแล้วก็ยังหาวิธีทำให้ Kafka Connect สามารถ failover จาก active cluster มาที่ standby cluster ได้ without external intervention โดยที่จะให้ Kafka Connect ต่อกับ cluster ตรงๆ ไม่ต้องผ่าน load balancer

คิดว่าวิธีที่ใกล้เคียงที่สุดคือใช้ health check script เพื่อดูว่า active cluster ระเบิดรึเปล่า ถ้าระเบิดก็ให้เปลี่ยน bootstrap server hostname สำหรับ Kafka Connect เพื่อให้มันต่อกับ standby cluster แล้วใช้แทนเป็น active แล้วค่อยให้ devops มาแก้กลับหลังจาก recover cluster เก่าหรือสร้าง cluster ใหม่ไปแล้ว

## Preparing for when Kafka cluster and Kafka Connect is gone

ถ้าจะโชคร้ายขนาดนี้ เริ่มไม่ทั้งหมดเลยดีกว่า =p

สิ่งที่ต้องเก็บ: env, Dockerfile, connector config ที่ใช้รันแล้วเริ่มจาก 0
