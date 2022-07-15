# daprPubSubExample
To run sample:
1. Let the dev container build
1. Once in VSCode, start debugging (F5)
1. Wait for message "I heard List Topic Subscription!"
1. Run the Direct Invoke Command:
  ````bash
  curl http://localhost:3500/v1.0/invoke/daprPubSubExample/method/helloworld
  ````
1.


# Direct invoke





# Request via pub/sub
curl http://localhost:3500/v1.0/publish/pubsub/foo \
  -H 'Content-Type: application/json' \
  -d '{ "Spartan117"}'