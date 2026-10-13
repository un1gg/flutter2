import firebase_admin
from firebase_admin import credentials
from firebase_admin import messaging

# Firebaseへの接続認証
cred = credentials.Certificate("【秘密鍵へのパス】")
firebase_admin.initialize_app(cred)

# メッセージ送信対象のデバイストークン
device_token = "【デバイストークン】"

# 通知メッセージ
message = messaging.Message(
    notification=messaging.Notification(
        title='メッセージのタイトル',
        body='メッセージの本文',
    ),
    token=device_token,
)

try:
    # メッセージの送信
    response = messaging.send(message)
    print('送信成功:', response)
except Exception as e:
    print('送信失敗:', e)
