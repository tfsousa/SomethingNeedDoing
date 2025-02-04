﻿using Dalamud.Utility;
using ECommons.DalamudServices;
using ECommons.GameHelpers;
using FFXIVClientStructs.FFXIV.Client.Game;
using FFXIVClientStructs.FFXIV.Client.Game.UI;
using FFXIVClientStructs.FFXIV.Client.System.Framework;
using FFXIVClientStructs.FFXIV.Client.UI.Agent;
using FFXIVClientStructs.FFXIV.Client.UI.Info;
using Lumina.Excel.GeneratedSheets;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace SomethingNeedDoing.Misc.Commands;

public class CharacterStateCommands
{
    internal static CharacterStateCommands Instance { get; } = new();

    public List<string> ListAllFunctions()
    {
        var methods = this.GetType().GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.FlattenHierarchy);
        var list = new List<string>();
        foreach (var method in methods.Where(x => x.Name != nameof(ListAllFunctions) && x.DeclaringType != typeof(object)))
        {
            var parameterList = method.GetParameters().Select(p => $"{p.ParameterType.Name} {p.Name}{(p.IsOptional ? " = " + (p.DefaultValue ?? "null") : "")}");
            list.Add($"{method.ReturnType.Name} {method.Name}({string.Join(", ", parameterList)})");
        }
        return list;
    }

    public bool IsPlayerAvailable() => Player.Interactable && !ECommons.GenericHelpers.IsOccupied();

    public unsafe bool HasStatus(string statusName)
    {
        statusName = statusName.ToLowerInvariant();
        var sheet = Service.DataManager.GetExcelSheet<Lumina.Excel.GeneratedSheets.Status>()!;
        var statusIDs = sheet
            .Where(row => row.Name.RawString.ToLowerInvariant() == statusName)
            .Select(row => row.RowId)
            .ToArray()!;

        return this.HasStatusId(statusIDs);
    }

    public unsafe bool HasStatusId(params uint[] statusIDs)
    {
        var statusID = Service.ClientState.LocalPlayer!.StatusList
            .Select(se => se.StatusId)
            .ToList().Intersect(statusIDs)
            .FirstOrDefault();

        return statusID != default;
    }

    public uint GetStatusStackCount(uint statusID) => Svc.ClientState.LocalPlayer?.StatusList.FirstOrDefault(x => x.StatusId == statusID)?.StackCount ?? 0;
    public float GetStatusTimeRemaining(uint statusID) => Svc.ClientState.LocalPlayer?.StatusList.FirstOrDefault(x => x.StatusId == statusID)?.RemainingTime ?? 0;
    public uint GetStatusSourceID(uint statusID) => Svc.ClientState.LocalPlayer?.StatusList.FirstOrDefault(x => x.StatusId == statusID)?.SourceId ?? 0;

    public bool GetCharacterCondition(int flagID, bool hasCondition = true) => hasCondition ? Service.Condition[flagID] : !Service.Condition[flagID];

    public string GetCharacterName(bool includeWorld = false) =>
        Service.ClientState.LocalPlayer == null ? "null"
        : includeWorld ? $"{Service.ClientState.LocalPlayer.Name}@{Service.ClientState.LocalPlayer.HomeWorld.GameData!.Name}"
        : Service.ClientState.LocalPlayer.Name.ToString();

    public bool IsInZone(int zoneID) => Service.ClientState.TerritoryType == zoneID;

    public bool IsLocalPlayerNull() => Service.ClientState.LocalPlayer == null;

    public bool IsPlayerDead() => Service.ClientState.LocalPlayer!.IsDead;

    public bool IsPlayerCasting() => Service.ClientState.LocalPlayer!.IsCasting;

    public unsafe bool IsMoving() => AgentMap.Instance()->IsPlayerMoving == 1;

    public bool IsPlayerOccupied() => ECommons.GenericHelpers.IsOccupied();

    public unsafe uint GetGil() => InventoryManager.Instance()->GetGil();

    public uint GetClassJobId() => Svc.ClientState.LocalPlayer!.ClassJob.Id;
    public uint GetHP() => Svc.ClientState.LocalPlayer?.CurrentHp ?? 0;
    public uint GetMaxHP() => Svc.ClientState.LocalPlayer?.MaxHp ?? 0;
    public uint GetMP() => Svc.ClientState.LocalPlayer?.CurrentMp ?? 0;
    public uint GetMaxMP() => Svc.ClientState.LocalPlayer?.MaxMp ?? 0;

    public float GetPlayerRawXPos(string character = "")
    {
        if (!character.IsNullOrEmpty())
        {
            unsafe
            {
                if (int.TryParse(character, out var p))
                {
                    var go = MiscHelpers.GetGameObjectFromPronounID((uint)(p + 42));
                    return go != null ? go->Position.X : -1;
                }
                else return Svc.Objects.Where(x => x.IsTargetable).FirstOrDefault(x => x.Name.ToString().Equals(character))?.Position.X ?? -1;
            }
        }
        return Svc.ClientState.LocalPlayer!.Position.X;
    }

    public float GetPlayerRawYPos(string character = "")
    {
        if (!character.IsNullOrEmpty())
        {
            unsafe
            {
                if (int.TryParse(character, out var p))
                {
                    var go = MiscHelpers.GetGameObjectFromPronounID((uint)(p + 42));
                    return go != null ? go->Position.Y : -1;
                }
                else return Svc.Objects.Where(x => x.IsTargetable).FirstOrDefault(x => x.Name.ToString().Equals(character))?.Position.Y ?? -1;
            }
        }
        return Svc.ClientState.LocalPlayer!.Position.Y;
    }

    public float GetPlayerRawZPos(string character = "")
    {
        if (!character.IsNullOrEmpty())
        {
            unsafe
            {
                if (int.TryParse(character, out var p))
                {
                    var go = MiscHelpers.GetGameObjectFromPronounID((uint)(p + 42));
                    return go != null ? go->Position.Z : -1;
                }
                else return Svc.Objects.Where(x => x.IsTargetable).FirstOrDefault(x => x.Name.ToString().Equals(character))?.Position.Z ?? -1;
            }
        }
        return Svc.ClientState.LocalPlayer!.Position.Z;
    }

    public unsafe int GetLevel(int expArrayIndex = -1)
    {
        if (expArrayIndex == -1) expArrayIndex = Svc.ClientState.LocalPlayer!.ClassJob.GameData!.ExpArrayIndex;
        return UIState.Instance()->PlayerState.ClassJobLevelArray[expArrayIndex];
    }

    public unsafe byte GetPlayerGC() => UIState.Instance()->PlayerState.GrandCompany;
    public unsafe int GetFCRank() => ((InfoProxyFreeCompany*)Framework.Instance()->UIModule->GetInfoModule()->GetInfoProxyById(InfoProxyId.FreeCompany))->Rank;
    public unsafe string GetFCGrandCompany() => ((InfoProxyFreeCompany*)Framework.Instance()->UIModule->GetInfoModule()->GetInfoProxyById(InfoProxyId.FreeCompany))->GrandCompany.ToString();
    public unsafe int GetFCOnlineMembers() => ((InfoProxyFreeCompany*)Framework.Instance()->UIModule->GetInfoModule()->GetInfoProxyById(InfoProxyId.FreeCompany))->OnlineMembers;
    public unsafe int GetFCTotalMembers() => ((InfoProxyFreeCompany*)Framework.Instance()->UIModule->GetInfoModule()->GetInfoProxyById(InfoProxyId.FreeCompany))->TotalMembers;

    public unsafe void RequestAchievementProgress(uint id) => FFXIVClientStructs.FFXIV.Client.Game.UI.Achievement.Instance()->RequestAchievementProgress(id);
    public unsafe uint GetRequestedAchievementProgress() => FFXIVClientStructs.FFXIV.Client.Game.UI.Achievement.Instance()->ProgressMax;
    public unsafe bool IsAchievementComplete(int id) => FFXIVClientStructs.FFXIV.Client.Game.UI.Achievement.Instance()->IsComplete(id); // requires the achievement menu to be loaded

    public unsafe uint GetCurrentBait() => PlayerState.Instance()->FishingBait;

    public unsafe ushort GetLimitBreakCurrentValue() => UIState.Instance()->LimitBreakController.CurrentValue;
    public unsafe uint GetLimitBreakBarValue() => UIState.Instance()->LimitBreakController.BarValue;
    public unsafe byte GetLimitBreakBarCount() => UIState.Instance()->LimitBreakController.BarCount;

    public unsafe uint GetPenaltyRemainingInMinutes() => UIState.Instance()->RouletteController.GetPenaltyRemainingInMinutes(0);

    public unsafe byte GetMaelstromGCRank() => PlayerState.Instance()->GCRankMaelstrom;
    public unsafe byte GetFlamesGCRank() => PlayerState.Instance()->GCRankImmortalFlames;
    public unsafe byte GetAddersGCRank() => PlayerState.Instance()->GCRankTwinAdders;
    public unsafe void SetMaelstromGCRank(byte rank) => PlayerState.Instance()->GCRankMaelstrom = rank;
    public unsafe void SetFlamesGCRank(byte rank) => PlayerState.Instance()->GCRankImmortalFlames = rank;
    public unsafe void SetAddersGCRank(byte rank) => PlayerState.Instance()->GCRankTwinAdders = rank;

    public unsafe bool HasFlightUnlocked(uint territory = 0) => PlayerState.Instance()->IsAetherCurrentZoneComplete(Svc.Data.GetExcelSheet<TerritoryType>()?.GetRow(territory != 0 ? territory : Svc.ClientState.TerritoryType)?.Unknown32 ?? 0);
}
