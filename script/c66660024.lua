--幻星集 星币国王
local m=66660024
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	xiaoye.CannotBeMaterialLink(c)
	xiaoye.LinkSummon(c)
	xiaoye.LinkToExtra(c,m)
	xiaoye.LinkSearch(c,cm.thfilter,m)
end
function cm.thfilter(c)
	return c:IsCode(66660030) or c:IsCode(66660028) and c:IsAbleToHand()
end