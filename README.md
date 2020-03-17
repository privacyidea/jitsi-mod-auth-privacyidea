This plugin adds 2FA authentication to Jitsi Meet.
Only users with a 2nd factor from privacyIDEA can start a meeting.
Others can join.

# Required debian packages

~~~~shell
apt install lua-json
apt install lua-sec
~~~~

# Setup

In the prosody config ``/etc/prosody/conf.avail/<yourdomain>.lua`` you have to 
add a line to your ``VirtualHost``:

~~~~
VirtualHost "<yourdomain>":
    authentication = "privacyidea"    
    privacyidea_config = {
        server = "https://your.privacyidea.server/validate/check";
        realm = "optionalrealm";
    }
~~~~

Then add another VirtualHost:

~~~~
VirtualHost "guest.<yourdomain>"
    authentication = "anonymous"
    c2s_require_encryption = false
~~~~

In ``/etc/prosody/prosody.cfg.lua`` you need to add:

~~~~
consider_bosh_secure = true;
~~~~

# Install

Copy the ``mod_auth_privacyidea.lua`` to your modules directory like
``/usr/lib/prosody/modules/``.




