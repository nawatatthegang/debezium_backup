# Debezium back up notes

## replication slot โดนลบ

- โดนลบตอน Debezium เกาะอยู่ไม่ได้ จะเจอ error ว่ามี PID ใช้งานอยู่
- ถ้า Kafka Connect ล่มแล้ว replication slot โดนลบระหว่างล่ม change ระหว่างเวลาที่ล่มไปจะหายหมด ต้องลบ cdc topic ใน
  Kafka แล้วเริ่มใหม่จาก initial snapshot

## ถ้า Postgres ล่มแต่ replication slot ไม่บึ้ม

- Debezium connector ใน Kafka Connect จะ fail แต่ Kafka Connect container จะไม่ล่ม ต้อง manual restart connector (ยิง
  curl command เข้าไป)
- สามารถ monitor status ได้ใน status topic ของ Kafka Connect (ตาม config ตอน deploy)

## ถ้า Debezium (i.e. server ที่รัน Kafka Connect) ระเบิด

- ตั้ง group id และชี้ config, status, offset topic ไปที่เดิมแล้วรัน
- ถ้าแค่ container ล่มก็สั่งรันใหม่ได้เลย Kafka Connect will do all the rest
- ถ้าอันเก่าไม่ล่มแล้วพยายามตั้งให้มันอ่านจาก replication slot เดียวกัน Debezium จะ error Postgres ดูว่าใครอ่าน
  replication slot ไหนผ่าน pid ของ connection

# Postgres cdc progress

- Postgres เก็บว่าอ่านถึงไหนไว้ใน replication slot