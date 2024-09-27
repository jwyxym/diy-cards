--春仙精 莉莉白
local m=16114254
local cm=_G["c"..m]
Duel.LoadScript("c16199990.lua")
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1) 
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cm.spcheck(c,e,tp)
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(cm.check,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
function cm.check(c,e,tp,att)
	return rk.check(c,"RYUUHA") and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and c:IsAttribute(att)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if e:GetLabel()==1 then
			return Duel.CheckReleaseGroup(REASON_COST,tp,cm.spcheck,1,nil,e,tp)  
		else
			return false
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(REASON_COST,tp,cm.spcheck,1,1,nil,e,tp)
	Duel.Release(g,REASON_COST)
	local tc=g:GetFirst()
	Duel.SetTargetParam(tc:GetAttribute())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.check,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,att)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end