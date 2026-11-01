{ pkgs, ... }:

# Claude reaches my Obsidian vault through the MCP endpoint of the Local REST API
# community plugin. The Claude desktop app only runs stdio servers, so
# obsidian-mcp bridges the plugin's HTTP endpoint to stdio, and Claude Code uses
# the same command. The API key stays in the login Keychain, set once with:
#   security add-generic-password -s obsidian-local-rest-api -a "$USER" -w
# The plugin's plain HTTP server must be on (it binds to 127.0.0.1), because the
# HTTPS one uses a self-signed certificate.
let
  obsidian-mcp = pkgs.writeShellApplication {
    name = "obsidian-mcp";
    runtimeInputs = [ pkgs.mcp-proxy ];
    text = ''
      key=$(/usr/bin/security find-generic-password -s obsidian-local-rest-api -w)
      exec mcp-proxy --transport streamablehttp \
        -H Authorization "Bearer $key" \
        http://127.0.0.1:27123/mcp/
    '';
  };
in
{
  home.packages = [ obsidian-mcp ];
}
