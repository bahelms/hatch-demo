curl -X POST http://localhost:4000/api/messages \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "from": "+1234567890",
      "to": "+0987654321",
      "type": "sms",
      "body": "Hello, world!",
      "attachments": ["heythere.jpg"],
      "timestamp": "2024-11-01T14:00:00Z"
    }
  }' | jq '.'
