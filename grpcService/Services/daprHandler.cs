using System.Text.Json;
using System.Text.Json.Serialization;
using Dapr.AppCallback.Autogen.Grpc.v1;
using Dapr.Client.Autogen.Grpc.v1;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

// Disable warning about async operators without await will run asynchronously
#pragma warning disable CS1998
namespace grpcService.Services;
public class DaprHandler : AppCallback.AppCallbackBase
{
    private readonly ILogger<DaprHandler> logger;

    public DaprHandler(ILogger<DaprHandler> logger)
    {
        this.logger = logger;
        this.logger.LogInformation("gRPC Service is starting up!");
    }


    /// <summary>
    /// Implement ListTopicSubscriptions to programmatically register for the topics offered by the SDK
    /// </summary>
    /// <param name="request"></param>
    /// <param name="context"></param>
    /// <returns></returns>
    public override async Task<ListTopicSubscriptionsResponse> ListTopicSubscriptions(Empty request, ServerCallContext context)
    {
        this.logger.LogInformation("I heard List Topic Subscription!");
        ListTopicSubscriptionsResponse resultListTopics = new ListTopicSubscriptionsResponse();

        //Always add the heartbeat
        resultListTopics.Subscriptions.Add(new TopicSubscription
        {
            PubsubName = "pubsub",
            Topic = "foo"
        });

        return resultListTopics;
    }

    public override async Task<TopicEventResponse> OnTopicEvent(TopicEventRequest request, ServerCallContext context)
    {
        Console.WriteLine("I heard a topic!");
        return new TopicEventResponse();
    }


    /// <summary>
    /// implement OnIvoke to support service-to-service method calls
    /// </summary>
    /// <param name="request"></param>
    /// <param name="context"></param>
    /// <returns></returns>
    public override async Task<InvokeResponse> OnInvoke(InvokeRequest request, ServerCallContext context)
    {
        Console.WriteLine("I heard a service invocation!");
        return new InvokeResponse();
    }
}