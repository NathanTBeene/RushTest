package.preload['server']=(function(...)local o=require("socket")local t={}t.__index=t
function t:new(n,o)local e=setmetatable({},t)e.config=n
e.consoles=o
e.tcp=nil
e.clients={}return e
end
function t:start()self.tcp=o.tcp()local e,t=self.tcp:bind("*",self.config.port)if not e then
error(string.format("[Conduit Server] Failed to bind to port %d: %s",self.config.port,t))end
self.tcp:listen(5)self.tcp:settimeout(0)print(string.format("[Conduit Server] Server started on http://localhost:%d",self.config.port))end
function t:stop()if self.tcp then
self.tcp:close()self.tcp=nil
end
for t,e in pairs(self.clients)do
if e.socket then
e.socket:close()end
end
self.clients={}print("[Conduit Server] Server stopped")end
function t:update()if not self.tcp then
return
end
self:_accept_connections()self:_process_connections()end
function t:_accept_connections()if not self.tcp then
return
end
local t,e=pcall(function()return self.tcp:accept()end)if not t then
print("[Conduit Server] Error accepting connection:",e)print("[Conduit Server] Restarting server...")self:stop()self:start()end
local e=e
if e then
e:settimeout(0)table.insert(self.clients,{socket=e,buffer="",start_time=o.gettime(),headers_complete=false,content_length=0,body_start=nil})end
end
function t:_process_connections()for s=#self.clients,1,-1 do
local e=self.clients[s]local t=false
local n=true
local a=0
while n and a<10 do
a=a+1
local l,s,a,o=pcall(function()return e.socket:receive(1024)end)if not l then
t=true
n=false
elseif s then
e.buffer=e.buffer..s
elseif o and#o>0 then
e.buffer=e.buffer..o
end
if a=="timeout"then
n=false
elseif a=="closed"then
t=true
n=false
elseif a then
t=true
n=false
end
end
if not e.headers_complete then
local t=string.find(e.buffer,"\r\n\r\n")if t then
e.headers_complete=true
e.body_start=t+4
local t=string.match(e.buffer,"Content%-Length: (%d+)")if t then
e.content_length=tonumber(t)end
end
end
if e.headers_complete then
local n=e.body_start+e.content_length-1
if#e.buffer>=n then
local e,n=pcall(function()self:_handle_request(e.socket,e.buffer)end)if not e then
print("[Conduit Server] Error handling request:",n)end
t=true
end
end
if o.gettime()-e.start_time>5 then
t=true
end
if t then
e.socket:close()table.remove(self.clients,s)end
end
end
function t:_handle_request(t,o)local e,n,a=string.match(o,"^(%w+) (%S+) (%S+)")if not e or not n then
self:_send_response(t,400,"text/plain","Bad Request")return
end
local e,a=string.match(n,"^([^%?]+)%?(.*)$")if not e then
e=n
a=""end
if e=="/"or e=="/index"or e=="/index.html"then
self:_serve_index(t)elseif string.match(e,"^/console/([a-z0-9_%-]+)$")then
local e=string.match(e,"^/console/([a-z0-9_%-]+)$")self:_serve_console(t,e)elseif string.match(e,"^/api/console/([a-z0-9_%-]+)/buffer$")then
local e=string.match(e,"^/api/console/([a-z0-9_%-]+)/buffer$")self:_api_console_buffer(t,e)elseif string.match(e,"^/api/console/([a-z0-9_%-]+)/logs$")then
local e=string.match(e,"^/api/console/([a-z0-9_%-]+)/logs$")self:_api_console_logs(t,e)elseif string.match(e,"^/api/console/([a-z0-9_%-]+)/command$")then
local e=string.match(e,"^/api/console/([a-z0-9_%-]+)/command$")self:_api_console_command(t,e,o)elseif string.match(e,"^/api/console/([a-z0-9_%-]+)/watchables$")then
local e=string.match(e,"^/api/console/([a-z0-9_%-]+)/watchables$")self:_api_console_watchables(t,e)elseif e=="/api/consoles"then
self:_api_consoles_list(t)elseif e=="/api/stats"then
self:_api_stats(t)else
self:_send_response(t,404,"text/plain","Not Found:  "..e)end
end
function t:_send_response(o,t,a,e)local n={[200]="OK",[400]="Bad Request",[404]="Not Found",[500]="Internal Server Error"}local e=string.format("HTTP/1.1 %d %s\r\n".."Content-Type: %s\r\n".."Content-Length: %d\r\n".."Connection: close\r\n".."\r\n".."%s",t,n[t]or"Unknown",a,#e,e)o:send(e)end
function t:_serve_index(t)local e=require("templates")local e=e.render_index(self.consoles,self.config)self:_send_response(t,200,"text/html",e)end
function t:_serve_console(t,e)local n=self.consoles[e]if not n then
self:_send_response(t,404,"text/plain","Console not found:  "..e)return
end
local e=require("templates")local e=e.render_console(n,self.config)self:_send_response(t,200,"text/html",e)end
function t:_api_console_buffer(e,t)local t=self.consoles[t]if not t then
self:_send_response(e,404,"text/plain","Console not found")return
end
local n=require("templates")local t=n.render_logs_buffer(t)self:_send_response(e,200,"text/html",t)end
function t:_api_console_logs(n,e)local e=self.consoles[e]if not e then
self:_send_response(n,404,"application/json",'{"error":"Console not found"}')return
end
local t=e:get_logs()local e=self:_encode_json({success=true,total=e.total_logs,count=#t,logs=t})self:_send_response(n,200,"application/json",e)end
function t:_api_console_command(e,n,t)local n=self.consoles[n]if not n then
self:_send_response(e,404,"application/json",'{"error":"Console not found"}')return
end
local o=string.find(t,"\r\n\r\n")if not o then
self:_send_response(e,400,"application/json",'{"error":"No request body"}')return
end
local t=string.sub(t,o+4)if not t or t==""then
self:_send_response(e,400,"application/json",'{"error":"Empty request body"}')return
end
local t=self:_decode_json(t)if not t or not t.command then
self:_send_response(e,400,"application/json",'{"error":"Missing command in JSON"}')return
end
local t=n:execute_command(t.command,t.args or{})local t=self:_encode_json(t)self:_send_response(e,200,"application/json",t)end
function t:_api_consoles_list(t)local e={}for n,t in pairs(self.consoles)do
table.insert(e,t:get_stats())end
local e=self:_encode_json({success=true,consoles=e})self:_send_response(t,200,"application/json",e)end
function t:_api_stats(s)local o=0
local n=0
local t=0
local e=0
for s,a in pairs(self.consoles)do
e=e+1
o=o+a.total_logs
for o,e in ipairs(a:get_logs())do
if e.level=="error"then
n=n+1
elseif e.level=="warning"then
t=t+1
end
end
end
local e=self:_encode_json({success=true,stats={console_count=e,total_logs=o,total_errors=n,total_warnings=t}})self:_send_response(s,200,"application/json",e)end
function t:_encode_json(a)local function n(e)local t=type(e)if t=="string"then
e=string.gsub(e,'\\','\\\\')e=string.gsub(e,'"','\\"')e=string.gsub(e,'\n','\\n')e=string.gsub(e,'\r','\\r')e=string.gsub(e,'\t','\\t')return'"'..e..'"'elseif t=="number"then
return tostring(e)elseif t=="boolean"then
return e and"true"or"false"elseif t=="nil"then
return"null"elseif t=="table"then
local o=true
local t=0
for e,n in pairs(e)do
t=t+1
if type(e)~="number"or e~=t then
o=false
break
end
end
if o and t>0 then
local t={}for o,e in ipairs(e)do
table.insert(t,n(e))end
return"["..table.concat(t,",").."]"else
local t={}for o,e in pairs(e)do
table.insert(t,n(tostring(o))..":"..n(e))end
return"{"..table.concat(t,",").."}"end
else
return"null"end
end
return n(a)end
function t:_decode_json(e)e=string.gsub(e,"^%s+","")e=string.gsub(e,"%s+$","")if e==""then
return nil
end
if string.sub(e,1,1)=="{"and string.sub(e,-1)=="}"then
local o={}local t=string.sub(e,2,-2)local e=1
while e<=#t do
while e<=#t and string.match(string.sub(t,e,e),"%s")do
e=e+1
end
if e>#t then break end
if string.sub(t,e,e)=='"'then
e=e+1
local n=e
while e<=#t and string.sub(t,e,e)~='"'do
e=e+1
end
local a=string.sub(t,n,e-1)e=e+1
while e<=#t and string.match(string.sub(t,e,e),"[%s:]")do
e=e+1
end
local n
if string.sub(t,e,e)=='"'then
e=e+1
local o=e
while e<=#t and string.sub(t,e,e)~='"'do
e=e+1
end
n=string.sub(t,o,e-1)e=e+1
else
local o=e
while e<=#t and not string.match(string.sub(t,e,e),"[,%s}]")do
e=e+1
end
local e=string.sub(t,o,e-1)if e=="true"then
n=true
elseif e=="false"then
n=false
elseif e=="null"then
n=nil
elseif tonumber(e)then
n=tonumber(e)else
n=e
end
end
o[a]=n
while e<=#t and string.match(string.sub(t,e,e),"[,%s]")do
e=e+1
end
else
break
end
end
return o
end
return nil
end
function t:_api_console_watchables(t,e)local e=self.consoles[e]if not e then
self:_send_response(t,404,"application/json",'{"error":"Console not found"}')return
end
local e=e:get_watchables()local e=self:_encode_json({success=true,groups=e})self:_send_response(t,200,"application/json",e)end
return t
end)package.preload['console']=(function(...)local e={}e.__index=e
local t={INFO={name="info",icon="▸",color="#c9d1d9"},SUCCESS={name="success",icon="✓",color="#3fb950"},WARNING={name="warning",icon="⚠",color="#d29922"},ERROR={name="error",icon="✖",color="#f85149"},DEBUG={name="debug",icon="○",color="#8b949e"},CUSTOM={name="custom",icon="▸",color="#c9d1d9"}}function e:new(n,t)local e=setmetatable({},e)e.name=n
e.max_logs=t.max_logs or 1e3
e.timestamps=t.timestamps or false
e.logs={}e.total_logs=0
e.commands={}e.watchables={}e.watchable_groups={}e.max_watchables=t.max_watchables or 100
return e
end
function e:_add_log(t,e)if type(e)~="string"then
e=tostring(e)end
local e={level=t.name,icon=t.icon,color=t.color,message=e,timestamp=self.timestamps and os.date("%H:%M:%S")or nil,id=self.total_logs+1}table.insert(self.logs,e)self.total_logs=self.total_logs+1
if#self.logs>self.max_logs then
table.remove(self.logs,1)end
end
function e:log(e)self:_add_log(t.INFO,e)end
function e:success(e)self:_add_log(t.SUCCESS,e)end
function e:warn(e)self:_add_log(t.WARNING,e)end
function e:error(e)self:_add_log(t.ERROR,e)end
function e:debug(e)self:_add_log(t.DEBUG,e)end
function e:clear()self.logs={}end
function e:get_logs()return self.logs
end
function e:register_command(e,t,n)if not e or type(e)~="string"then
error("[Conduit] Command name must be a string")end
if not t or type(t)~="function"then
error("[Conduit] Command callback must be a function")end
self.commands[e]={callback=t,description=n or"No description"}end
function e:execute_command(e,t)if not self.commands[e]then
local e=string.format("Command '%s' not found. Type 'help' for a list of commands.",e)self:error(e)return{success=false,message=e}end
local n,t=pcall(self.commands[e].callback,self,t or{})if not n then
local e=string.format("Error executing command '%s': %s",e,tostring(t))self:error(e)return{success=false,message=tostring(t)}end
return{success=true,message="Command executed successfully."}end
function e:count_commands()local e=0
for t in pairs(self.commands)do
e=e+1
end
return e
end
function e:watch(e,t,n,o)if not e or type(e)~="string"then
error("[Conduit] Watchable name must be a string")self:warn("Invalid name for watchable. Must be a string.")end
if not t or type(t)~="function"then
error("[Conduit] Watchable getter must be a function")self:warn("Invalid getter for watchable '"..e.."'. Must be a function.")end
if#self.watchables>=self.max_watchables then
error("[Conduit] Maximum number of watchables reached")self:warn("Maximum number of watchables reached. Cannot add '"..e.."'.")end
n=n or"Other"o=o or 999
self.watchables[e]={getter=t,group=n,order=o}end
function e:group(e,t)if not e or type(e)~="string"then
error("[Conduit] Watchable group name must be a string")end
t=t or 999
self.watchable_groups[e]=t
end
function e:unwatch(e)self.watchables[e]=nil
self._recalculate_group_orders()end
function e:unwatch_group(t)for n,e in pairs(self.watchables)do
if e.group==t then
self.watchables[n]=nil
end
end
end
function e:get_watchables()local t={}local o={}for a,n in pairs(self.watchables)do
local e=n.group
if not o[e]then
local n={name=e,order=self.watchable_groups[e]or 999,items={}}table.insert(t,n)o[e]=n
end
local s,t=pcall(n.getter)local t=s and tostring(t)or("Error: "..tostring(t))table.insert(o[e].items,{name=a,value=t,order=n.order})end
table.sort(t,function(e,t)return e.order<t.order
end)for t,e in ipairs(t)do
table.sort(e.items,function(e,t)return e.order<t.order
end)end
return t
end
function e:get_stats()return{name=self.name,log_count=#self.logs,total_logs=self.total_logs,max_logs=self.max_logs,command_count=self:count_commands()}end
return e
end)package.preload['templates']=(function(...)local t={}local s=[[
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    html, body {
        height: 100%;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
        background-color: #0d1117;
        color: #c9d1d9;
    }

    /* Header */
    . header {
        background-color:  #161b22;
        border-bottom: 1px solid #30363d;
        padding: 16px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .header-left {
        display: flex;
        align-items: center;
        gap: 16px;
        padding: 8px;
    }

    .logo {
        font-size: 20px;
        font-weight: 600;
        color: #58a6ff;
        letter-spacing: 0.5px;
        text-decoration: none;
        transition: color 0.2s;
    }

    .logo:hover {
        color:  #79c0ff;
    }

    .console-name {
        font-size: 16px;
        color: #8b949e;
        padding-left: 16px;
        border-left: 1px solid #30363d;
        text-transform: capitalize;
    }

    /* Toolbar */
    .toolbar {
        background-color: #161b22;
        border-bottom: 1px solid #30363d;
        padding:  12px 20px;
        display: flex;
        gap: 12px;
        align-items:  center;
    }

    .search-container {
        display: flex;
        gap: 8px;
        align-items: center;
        flex: 1;
    }

    .search-container input,
    .search-container select {
        background-color: #0d1117;
        color: #c9d1d9;
        border: 1px solid #30363d;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 14px;
        transition: border-color 0.2s;
    }

    .btn {
        background-color: #21262d;
        color: #c9d1d9;
        border: 1px solid #30363d;
        padding: 6px 16px;
        border-radius:  6px;
        font-size: 14px;
        cursor: pointer;
        transition: background-color 0.2s, border-color 0.2s;
    }

    .btn:hover {
        background-color: #30363d;
        border-color: #58a6ff;
    }

    /* Log Container */
    .log-container {
        flex: 1;
        overflow-y: auto;
        overflow-x: hidden;
        padding: 20px;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 14px;
        line-height: 1.6;
    }

    .log-entry {
        padding: 4px 8px;
        margin-bottom: 2px;
        border-radius:  3px;
        display: flex;
        align-items: flex-start;
        gap: 8px;
    }

    .log-entry:hover {
        background-color:  #161b22;
    }

    .log-icon {
        flex-shrink: 0;
        width: 16px;
        text-align: center;
    }

    .log-message {
        flex: 1;
        display: flex;
    }

    .log-timestamp {
        color: #8b949e;
        margin-right: 8px;
    }

    .message-text {
        flex: 1;
        color: inherit;
    }

    /* Command Input */
    .command-input-container {
        background-color: #161b22;
        border-top: 1px solid #30363d;
        padding: 12px 20px;
    }

    .command-input-wrapper {
        display: flex;
        gap: 8px;
        align-items: center;
    }

    .command-prompt {
        color: #58a6ff;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 14px;
        font-weight: bold;
    }

    .command-input {
        flex: 1;
        background-color: #0d1117;
        color:  #c9d1d9;
        border: 1px solid #30363d;
        padding: 8px 12px;
        border-radius: 6px;
        font-family:  'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 14px;
        transition: border-color 0.2s;
    }

    .command-input:focus {
        outline: none;
        border-color: #58a6ff;
    }

    .command-help {
        font-size: 11px;
        color: #8b949e;
        margin-top: 6px;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    }

    /* Status Bar */
    .status-bar {
        background-color: #161b22;
        border-top: 1px solid #30363d;
        padding: 8px 20px;
        font-size: 12px;
        color: #8b949e;
        display:  flex;
        justify-content:  space-between;
    }

    /* Index Page Specific */
    .index-container {
        max-width: 900px;
        margin: 40px auto;
        padding: 0 20px;
    }

    .section-title {
        font-size:  20px;
        font-weight: 600;
        margin-bottom: 16px;
        color: #c9d1d9;
    }

    .console-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 16px;
        margin-bottom: 40px;
    }

    .console-card {
        background-color: #161b22;
        border: 1px solid #30363d;
        border-radius: 8px;
        padding: 20px;
        transition: border-color 0.2s, transform 0.2s;
        cursor: pointer;
        text-decoration: none;
        color: inherit;
        display: block;
    }

    .console-card:hover {
        border-color: #58a6ff;
        transform: translateY(-2px);
    }

    .console-card-title {
        font-size:  18px;
        font-weight:  600;
        color: #58a6ff;
        text-transform: capitalize;
        margin-bottom: 8px;
    }

    .console-card-info {
        font-size: 13px;
        color: #8b949e;
    }

    .stats-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
    }

    .stat-card {
        background-color:  #161b22;
        border: 1px solid #30363d;
        border-radius:  8px;
        padding:  20px;
    }

    .stat-value {
        font-size:  32px;
        font-weight:  600;
        color: #58a6ff;
        margin-bottom: 4px;
    }

    .stat-label {
        font-size: 14px;
        color: #8b949e;
    }

    /* Console Page Layout */
    .console-page {
        display: flex;
        flex-direction: column;
        height: 100vh;
        overflow: hidden;
    }

    .console-content {
      display: flex;
      flex: 1;
      overflow: hidden;
    }

    .watchables-panel {
        width:  350px;
        background-color:  #0d1117;
        border-left: 1px solid #30363d;
        padding: 16px;
        overflow-y:  auto;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .watchables-header {
        font-size: 14px;
        font-weight: 600;
        color: #8b949e;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding-bottom: 8px;
        border-bottom: 1px solid #30363d;
    }

    .watchable-group {
        background-color: #161b22;
        border:  1px solid #30363d;
        border-radius: 6px;
        padding: 12px;
    }

    .watchable-group-title {
        font-size: 12px;
        font-weight: 600;
        color:  #58a6ff;
        text-transform: uppercase;
        margin-bottom: 8px;
        letter-spacing: 0.3px;
    }

    .watchable-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 6px 8px;
        margin-bottom:  4px;
        background-color: #0d1117;
        border-radius: 4px;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 13px;
    }

    .watchable-item: last-child {
        margin-bottom: 0;
    }

    .watchable-name {
        color: #8b949e;
        flex:  1;
        align-self:  baseline;
    }

    .watchable-value {
        color: #3fb950;
        font-weight:  600;
        text-align: right;
        margin-left: 12px;
        white-space: pre-wrap;
    }
</style>
]]local i=[[
<script>
    const logContainer = document.getElementById('logContainer');
    const commandInput = document.getElementById('commandInput');
    const commandHelp = document.getElementById('commandHelp');
    const clearBtn = document.getElementById('clearBtn');
    const statusIndicator = document.getElementById('statusIndicator');
    const searchInput = document.getElementById('searchInput');
    const searchDropdown = document.getElementById('searchDropdown');
    const watchablesContainer = document.getElementById('watchablesContainer');

    let contentCache = '';
    let watchablesCache = '';
    let isAtBottom = true;
    let commandHistory = [];
    let historyIndex = -1;

    // Check if user is scrolled to bottom
    function checkIfAtBottom() {
        const threshold = 50;
        isAtBottom = logContainer.scrollHeight - logContainer.scrollTop - logContainer.clientHeight < threshold;
    }

    logContainer.addEventListener('scroll', checkIfAtBottom);

    // Search Fliter
    function filterLogs()
    {
      const search = searchInput.value.toLowerCase();
      const type = searchDropdown.value;
      const entries = logContainer.querySelectorAll('.log-entry');

      entries.forEach(entry => {
        const logType = entry.getAttribute('data-type');
        const matchesType = (type === 'all' || logType === type);

        // Get log-message element
        const messageElement = entry.querySelector('.log-message');
        let messageText = messageElement.textContent || messageElement.innerText;

        // Remove timestamp
        const timestampElem = messageElement.querySelector('.log-timestamp');
        if (timestampElem) {
          messageText = messageText.replace(timestampElem.textContent, '').trim();
        }

        const matchesSearch = messageText.toLowerCase().includes(search);

        entry.style.display = (matchesType && matchesSearch) ? '' : 'none';
      });
    }

    searchInput.addEventListener('input', filterLogs);
    searchDropdown.addEventListener('change', filterLogs);

    // Fetch and update logs via AJAX
    function refreshLogs() {
        fetch('/api/console/{{CONSOLE_NAME}}/buffer')
            .then(response => response.text())
            .then(html => {
                // Only update if content changed
                if (html !== contentCache) {
                    const wasAtBottom = isAtBottom;
                    logContainer.innerHTML = html;
                    contentCache = html;

                    // Auto-scroll only if was at bottom
                    if (wasAtBottom) {
                        logContainer.scrollTop = logContainer.scrollHeight;
                    }

                    filterLogs();
                }
                statusIndicator.innerHTML = 'Connected • Live';
            })
            .catch(err => {
                statusIndicator.innerHTML = 'Disconnected &#9675;';
            });
    }

    // Execute command
    function executeCommand(commandText) {
        if (!commandText.trim()) return;

        // Add to history
        if (commandHistory[0] !== commandText) {
            commandHistory.unshift(commandText);
            if (commandHistory.length > 50) commandHistory.pop();
        }
        historyIndex = -1;

        // Send command to server
        fetch('/api/console/{{CONSOLE_NAME}}/command', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ command: commandText })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                commandHelp.textContent = '✓ ' + (data.message || 'Command executed');
                commandHelp.style. color = '#3fb950';
            } else {
                commandHelp.textContent = '✗ ' + (data.error || 'Command failed');
                commandHelp. style.color = '#f85149';
            }
            setTimeout(() => {
                commandHelp.textContent = 'Press Enter to execute • Type "help" for commands';
                commandHelp.style.color = '#8b949e';
            }, 3000);
            refreshLogs();
        })
        .catch(err => {
            commandHelp.textContent = '✗ Failed to execute command';
            commandHelp.style.color = '#f85149';
        });

        // Clear input
        commandInput.value = '';
    }

    // Command input event handlers
    commandInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            executeCommand(commandInput.value);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (historyIndex < commandHistory.length - 1) {
                historyIndex++;
                commandInput.value = commandHistory[historyIndex];
            }
        } else if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (historyIndex > 0) {
                historyIndex--;
                commandInput.value = commandHistory[historyIndex];
            } else if (historyIndex === 0) {
                historyIndex = -1;
                commandInput.value = '';
            }
        }
    });

    // Fetch and update watchables
    function refreshWatchables() {
        fetch('/api/console/{{CONSOLE_NAME}}/watchables')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    let html = '';

                    if (data.groups. length === 0) {
                        html = '<p style="color: #8b949e; font-size: 12px; text-align: center;">No watchables yet.</p>';
                    } else {
                        data.groups. forEach(group => {
                            html += `
                                <div class="watchable-group">
                                    <div class="watchable-group-title">${group.name}</div>
                            `;

                            group.items.forEach(item => {
                                html += `
                                    <div class="watchable-item">
                                        <span class="watchable-name">${item.name}</span>
                                        <span class="watchable-value">${item.value}</span>
                                    </div>
                                `;
                            });

                            html += '</div>';
                        });
                    }

                    if (html !== watchablesCache) {
                        watchablesContainer.innerHTML = html;
                        watchablesCache = html;
                    }
                }
            })
            .catch(err => {
                console.error('Failed to fetch watchables:', err);
            });
    }

    // Clear button
    clearBtn.addEventListener('click', () => {
        executeCommand('clear');
    });

    // Initial scroll to bottom
    logContainer.scrollTop = logContainer.scrollHeight;
    isAtBottom = true;

    // Poll every 200ms for low latency
    setInterval(refreshLogs, {{REFRESH_INTERVAL}});
    setInterval(refreshWatchables, {{REFRESH_INTERVAL}});
</script>
]]local r=[[
<script>
    let consoleCache = '';

    function updateIndex() {
        // Update console list
        fetch('/api/consoles')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    let html = '';
                    data.consoles.forEach(console => {
                        html += `
                            <a href="/console/${console.name}" class="console-card">
                                <div class="console-card-title">${console.name}</div>
                                <div class="console-card-info">${console.log_count} logs</div>
                            </a>
                        `;
                    });

                    if (html !== consoleCache) {
                        const grid = document.getElementById('consoleGrid');
                        grid.innerHTML = html || '<p style="color: #8b949e;">No consoles created yet. </p>';
                        consoleCache = html;
                    }
                }
            })
            .catch(err => {});

        // Update stats
        fetch('/api/stats')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('statConsoles').textContent = data.stats.console_count;
                    document. getElementById('statLogs').textContent = data.stats.total_logs;
                    document.getElementById('statErrors').textContent = data.stats. total_errors;
                    document.getElementById('statWarnings').textContent = data.stats.total_warnings;
                }
            })
            .catch(err => {});
    }

    // Update every REFRESH_INTERVAL ms
    setInterval(updateIndex, {{REFRESH_INTERVAL}});
</script>
]]function t.render_index(l,i)local t={}for e,n in pairs(l)do
local n=n:get_stats()table.insert(t,string.format([[
      <a href="/console/%s" class="console-card">
        <div class="console-card-title">%s</div>
        <div class="console-card-info">%d logs</div>
      </a>
    ]],e,e,n.log_count))end
local a=table.concat(t,"\n")if a==""then
a='<p style="color: #8b949e; padding: 40px; text-align: center;">No consoles created yet.</p>'end
local o=0
local n=0
local e=0
local t=0
for s,a in pairs(l)do
t=t+1
o=o+a.total_logs
for o,t in ipairs(a:get_logs())do
if t.level=="error"then
n=n+1
elseif t.level=="warning"then
e=e+1
end
end
end
local l=r:gsub("{{REFRESH_INTERVAL}}",tostring(i.refresh_interval or 500))return string.format([[
    <! DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Conduit - Console Index</title>
      %s
    </head>
    <body>
        <div class="header">
            <div class="header-left">
                <a href="/" class="logo">CONDUIT</a>
            </div>
        </div>

        <div class="index-container">
            <h2 class="section-title">Active Consoles</h2>
            <div class="console-grid" id="consoleGrid">
                %s
            </div>

            <h2 class="section-title">Statistics</h2>
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-value" id="statConsoles">%d</div>
                    <div class="stat-label">Consoles</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="statLogs">%d</div>
                    <div class="stat-label">Total Logs</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="statErrors">%d</div>
                    <div class="stat-label">Errors</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="statWarnings">%d</div>
                    <div class="stat-label">Warnings</div>
                </div>
            </div>
        </div>

        %s
    </body>
    </html>
    ]],s,a,t,o,n,e,l)end
function t.render_console(e,n)local o=t.render_logs_buffer(e)local t=i:gsub("{{CONSOLE_NAME}}",e.name):gsub("{{REFRESH_INTERVAL}}",tostring(n.refresh_interval or 200))return string.format([[
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Conduit - %s</title>
        %s
    </head>
    <body class="console-page">
        <div class="header">
            <div class="header-left">
                <a href="/" class="logo">CONDUIT</a>
                <div class="console-name">%s</div>
            </div>
        </div>

        <div class="toolbar">
            <div class="search-container">
                <input type="text" id="searchInput" placeholder="Search...">
                <select name="search-dropdown" id="searchDropdown">
                      <option value="all" style="color: #c9d1d9;">All</option>
                      <option value="info" style="color: #c9d1d9;">▸ info</option>
                      <option value="success" style="color: #3fb950;">✓ success</option>
                      <option value="warning" style="color: #d29922;">⚠ warning</option>
                      <option value="error" style="color: #f85149;">✖ error</option>
                      <option value="debug" style="color: #8b949e;">○ debug</option>
                      <option value="custom" style="color: #c9d1d9;">▸ custom</option>

                </select>
            </div>
            <button class="btn" id="clearBtn">Clear</button>
        </div>

        <div class="console-content">
          <div class="log-container" id="logContainer">
              %s
          </div>

          <div class="watchables-panel">
              <div class="watchables-header">
                  Watchables
              </div>
              <div id="watchablesContainer">
                  <!-- Watchables will be dynamically loaded here -->
              </div>
          </div>
        </div>

        <div class="command-input-container">
            <div class="command-input-wrapper">
                <span class="command-prompt">&gt;</span>
                <input type="text" class="command-input" id="commandInput"
                      placeholder="Type a command...  (try 'help')" autocomplete="off">
            </div>
            <div class="command-help" id="commandHelp">
                Press Enter to execute • Type "help" for commands
            </div>
        </div>

        <div class="status-bar">
            <span>Total Logs: <strong>%d</strong></span>
            <span id="statusIndicator">Connected • Live</span>
        </div>

        %s
    </body>
    </html>
  ]],e.name,s,e.name,o,e.total_logs,t)end
local function o(e)return e:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;"):gsub("'","&#39;")end
function t.render_logs_buffer(e)local e=e:get_logs()if#e==0 then
return[[
      <div style="text-align: center; padding: 40px; color: #8b949e;">
      <p>No logs yet.</p>
      <p style="font-size: 12px; margin-top: 8px;">
        Start logging with <code>console: log("message")</code>
      </p>
      </div>
    ]]end
local n={}for t,e in ipairs(e)do
local t=""if e.timestamp then
t=string.format('<span class="log-timestamp">[%s]</span> ',e.timestamp)end
local o=o(e.message):gsub("\n","<br>")local e=string.format([[
      <div class="log-entry" style="color: %s;" data-type="%s">
        <span class="log-icon">%s</span>
        <span class="log-message">
          %s
          <span class="message-text">
            %s
          </span>
        </span>
      </div>
    ]],e.color,e.level or"custom",e.icon,t,o)table.insert(n,e)end
return table.concat(n,"\n")end
return t
end)local t={}local n={}local s={port=8080,timestamps=true,max_logs=1e3,max_watchables=100,refresh_interval=200}local e=nil
local a=false
local o={}function t:init(o)if a then
print("[Conduit] Already initialized")return
end
if o then
for e,t in pairs(o)do
s[e]=t
end
end
t:_define_global_commands()local t=require("server")e=t:new(s,n)e:start()a=true
print(string.format("[Conduit] Initialized on http://localhost:%d",s.port))end
function t:update()if e then
e:update()end
end
function t:shutdown()if e then
e:stop()end
a=false
n={}print("[Conduit] Shutdown complete")end
function t:console(e)if not a then
self:init({})end
if not e or type(e)~="string"or e==""then
error("[Conduit] Console name must be a non-empty string")end
e=e:lower():gsub("[^%w_%-]","")if n[e]then
return n[e]end
local a=require("console")local a=a:new(e,s)for t,e in pairs(o)do
a:register_command(t,e.callback,e.description)end
n[e]=a
t[e]=a
print(string.format("[Conduit] Created new console '%s'.",e))return a
end
function t:clear_consoles()for t,e in pairs(n)do
e:clear()end
print("[Conduit] All consoles cleared")end
function t:_define_global_commands()o["help"]={callback=function(t,e)local n={"=== Available Commands ===\n"}local e={}for n,t in pairs(t.commands)do
table.insert(e,{name=n,desc=t.description})end
table.sort(e,function(e,t)return e.name<t.name end)for o,e in ipairs(e)do
table.insert(n,string.format("  %s - %s",e.name,e.desc))end
t:log(table.concat(n,"\n"))end,description="Show all available commands"}o["clear"]={callback=function(e,t)e:clear()e:log("Console cleared")end,description="Clear all logs from this console"}o["stats"]={callback=function(t,e)local e=t:get_stats()local e={"=== Console Statistics ===\n",string.format("Name: %s",e.name),string.format("Current logs: %d",e.log_count),string.format("Total logs written: %d",e.total_logs),string.format("Max logs: %d",e.max_logs),string.format("Commands available: %d",e.command_count)}t:log(table.concat(e,"\n"))end,description="Show statistics for this console"}end
function t:register_global_command(e,s,t)if not a then
self:init({})end
o[e]={callback=s,description=t or"No description"}for o,n in pairs(n)do
n:register_command(e,s,t)end
print(string.format("[Conduit] Registered global command '%s'",e))end
return t
