-- Prosody IM
-- based on mod_auth_common_http by
-- Copyright (C) 2008-2010 Waqas Hussain
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--
-- Copyright (C) 2020   cornelius.koelbel@netknights.it

local log = module._log;
local new_sasl = require "util.sasl".new;
local json = require "util.json";
local https = require "ssl.https";
local ltn12 = require("ltn12")
local options = module:get_option("privacyidea_config");
local server_url = options and options.server;
assert(server_url, "No privacyIDEA server URL provided");
local realm = options and options.realm;

local provider = {};

function provider.test_password(username, password)
        return nil, "Not supported";
end

function provider.get_password(username)
        return nil, "Not supported"
end

function provider.set_password(username, password)
        return nil, "Not supported"
end

function provider.user_exists(username)
        return true;
end

function provider.create_user(username, password)
        return nil, "Not supported"
end

function provider.delete_user(username)
        return nil, "Not supported"
end

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

function provider.get_sasl_handler()
        -- log("info", "in SASL handler");
        local getpass_authentication_profile = {
                -- log("info", "in profile");
                plain_test = function(sasl, username, password, realm)
                        local chunks = {};
                        local payload = "user="..urlencode(username).."&pass="..urlencode(password);
                        -- log("info", "user: %s", username);
                        -- log("info", "realm: %s", realm);
                        -- log("info", "pass: %s", password);
                        local r, c, h, s = https.request { 
                                url = server_url, 
                                method = "POST",
                                headers = {
                                        ["Content-Type"] =  "application/x-www-form-urlencoded",
                                        ["Content-Length"] = string.len(payload)
                                     },
                                source = ltn12.source.string(payload),
                                sink = ltn12.sink.table(chunks) };
                        if c == 200 then
                                local resp = table.concat(chunks);
                                local answer = json.decode(resp);
                                log("info", "Received HTTP 200 from privacyIDEA server.");
                                log("debug", resp);
                                log("debug", "r: %s", r);
                                log("debug", "c: %s", c);
                                log("debug", "h: %s", h);
                                log("debug", "s: %s", s);
                                if answer.result.status then
                                        log("info", "Result.status is True");
                                        if answer.result.value then
                                                log("info", "User %s successfully authenticated.", username);
                                                return username, true
                                        end
                                end
                        end
                        
                        return nil, true;
                end
        };
        return new_sasl(realm, getpass_authentication_profile);
end


module:provides("auth", provider);

