#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <warmix>

#pragma newdecls required
#pragma semicolon 1


public Plugin myinfo =
{
	name = "BuyZone",
	author = "Laravelka",
	description = "",
	version = "1.0.0",
	url = "https://github.com/Laravelka/BuyZone"
};

bool g_isCreateTime;
ConVar g_BuyZoneRange;

public void OnPluginStart()
{
	g_BuyZoneRange = CreateConVar("buyzone_on", "1", "0 = default 1 = everywhere 2 = nowhere", 0, false, 0.0, false, 0.0);
	
	if (g_BuyZoneRange)
	{
		HookConVarChange(g_BuyZoneRange, OnCvarChange);
	}

	HookEvent("player_death", EventPlayerDeath);
	HookEvent("player_spawn", EventPlayerSpawn);
	HookEvent("player_disconnect", EventPlayerDisconnect);
}

public void OnMapStart()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_buyzone")) != -1)
	{
		AcceptEntityInput(entity, "Disable", -1, -1, 0);
	}
}

public void OnCvarChange(Handle hCVar, const char[] oldCvar, const char[] newCvar)
{
	int value = StringToInt(newCvar[0], 10);
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_buyzone")) != -1)
	{
		if (value < 2)
		{
			AcceptEntityInput(entity, "Enable", -1, -1, 0);
		}
		else
		{
			if (value == 2)
			{
				AcceptEntityInput(entity, "Disable", -1, -1, 0);
			}
		}
	}
}

public Action EventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid", 0));
	SDKUnhook(client, SDKHook_PostThinkPost, OnThinkPost);

	return Plugin_Continue;
}

public Action EventPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid", 0));
	SDKUnhook(client, SDKHook_PostThinkPost, OnThinkPost);

	return Plugin_Continue;
}

public Action EventPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid", 0));
	SDKUnhook(client, SDKHook_PostThinkPost, OnThinkPost);

	g_BuyZoneRange.SetInt(1, false, false);

	if (IsClientInGame(client) && g_BuyZoneRange.IntValue == 1 && GetClientTeam(client) < 2)
	{
		return Plugin_Handled;
	}

	SDKHook(client, SDKHook_PostThinkPost, OnThinkPost);
	CreateTimer(0.15, Timer_Delay, event.GetInt("userid", 0), 0);

	return Plugin_Continue;
}

public Action OnThinkPost(int client, any other)
{
	if (g_BuyZoneRange.IntValue == 1)
	{
		SetEntProp(client, Prop_Send, "m_bInBuyZone", 1);
	} else {
		SetEntProp(client, Prop_Send, "m_bInBuyZone", 0);
	}

	return Plugin_Continue;
}

public Action Timer_BuyZone(Handle hTimer, int userId)
{
	if (WarMix_IsMatchLive())
	{
		g_BuyZoneRange.SetInt(2, false, false);
	}
	return Plugin_Continue;
}

public Action Timer_Delay(Handle hTimer, int userId)
{
	if (g_isCreateTime == true)
	{
		CreateTimer(10.0, Timer_BuyZone, userId, 0);
	}
	return Plugin_Continue;
}

public int WarMix_OnMatchEnd()
{
	g_isCreateTime = false;

	return 0;
}

public int WarMix_OnMatchHalfTime()
{
	g_isCreateTime = false;

	return 0;
}

public int WarMix_OnMatchOvertime()
{
	g_isCreateTime = false;

	return 0;
}

public int WarMix_OnRestartsCompleted()
{
	g_isCreateTime = true;

	return 0;
}