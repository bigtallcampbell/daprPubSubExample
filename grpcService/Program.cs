using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace grpcService {
    public class Program {
        readonly static JsonSerializerOptions jsonOptions = new JsonSerializerOptions { DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingDefault, PropertyNameCaseInsensitive = false };

        public static void Main(string[] args) {
            CreateHostBuilder().Build().Run();
        }

        /// <summary>
        /// Creates the gRPC instance to listen for SDK messages
        /// </summary>
        /// <returns>SpaceFxClient</returns>
        internal static IHostBuilder CreateHostBuilder() =>

        Host.CreateDefaultBuilder()
            .ConfigureWebHostDefaults(webBuilder => {
                webBuilder.ConfigureKestrel(options => {
                    // Setup a HTTP/2 endpoint without TLS.
                    options.ListenLocalhost(50051, o => o.Protocols = HttpProtocols.Http2);
                });

                webBuilder.UseStartup<Receiver_Config>();
            });

        /// <summary>
        /// gRPC Configuration setup
        /// </summary>
        /// <returns>SpaceFxClient</returns>
        internal class Receiver_Config {
            /// <summary>
            /// Configure Services
            /// </summary>
            /// <param name="services"></param>
            public void ConfigureServices(IServiceCollection services) {
                services.AddMemoryCache();
                services.AddGrpc();

            }

            /// <summary>
            /// Configure app
            /// </summary>
            /// <param name="app"></param>
            /// <param name="env"></param>
            public void Configure(IApplicationBuilder app, IWebHostEnvironment env) {
                if (env.IsDevelopment()) {
                    app.UseDeveloperExceptionPage();
                }

                app.UseRouting();
                app.UseEndpoints(endpoints => {
                    endpoints.MapGrpcService<Services.DaprHandler>();
                });
            }
        }
    }
}
