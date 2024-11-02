--幻星集 权杖国王
local m=66660023
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	xiaoye.CannotBeMaterialLink(c)
	xiaoye.LinkSummon(c)
	xiaoye.LinkToExtra(c,m)
	xiaoye.LinkSearch(c,cm.thfilter,m)
end
function cm.thfilter(c)
	return (c:IsSetCard(0x666) and c:IsType(TYPE_FIELD)) or c:IsCode(66660027) and c:IsAbleToHand()
end