import ballerina/io;
import ballerina/http;
import ballerina/mime;

endpoint http:Listener servicEp {
    port:9090
};

@http:ServiceConfig {
    basePath:"/hello",
    webSocketUpgrade:{
                         upgradePath:"/ws",
                         upgradeService:wsService
                     }
}
service<http:Service> httpService bind servicEp {

    @http:ResourceConfig {
        path:"/world",
        methods:["POST", "GET", "PUT", "My"]
    }
    httpResource (endpoint conn, http:Request req) {
        http:Response resp = new;
        var payload = req.getStringPayload();
        match payload {
            http:PayloadError payloadError => {
                io:println(payloadError.message);
                resp.setStringPayload(payloadError.message);
                resp.statusCode = 500;
            }
            string val => {
                io:println(payload);
                resp.setStringPayload("I received");
            }
        }

        _ = conn -> respond(resp);
    }
}

@Description {value:"When a WebSocket upgrade path is defined under HTTP in the WebSocket configuration, there can be \n - Full service configuration: Two base paths for the same service from either HTTP or WebSocket. \n - Without service configuration: WebSocket service is a slave service of the HTTP service. Only the upgrade path can be there. \n - Configuration without basePath: Acts as a slave service but can configure sub protocols, idle timeout, etc."}
@http:WebSocketServiceConfig {
    subProtocols:["xml, json"],
    idleTimeoutInSeconds:5
}
service<http:WebSocketService> wsService {

    onOpen (endpoint ep) {
        var conn = ep.getClient();
        io:println("New WebSocket connection: " + ep.id);
    }

    onText (endpoint ep, string text) {
        io:println(text);
        _ = ep -> pushText(text);
    }

    onIdleTimeout (endpoint ep) {
        var conn = ep.getClient();
        io:println("Idle timeout: " + ep.id);
    }
}
