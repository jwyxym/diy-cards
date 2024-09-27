--龙素记号 Sb
xpcall(function() dofile("expansions/script/c16199990.lua") end,function() dofile("script/c16199990.lua") end)
local m,cm=rk.set(16114235)
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_COF)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--Activate_2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.activate)
	c:RegisterEffect(e2) 
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentChain()==0
end
function cm.spcheck(c,e,tp)
	return c:IsSetCard(0xccf) and c:IsAbleToDeck() and c:IsFaceup() and Duel.IsExistingMatchingCard(cm.check,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
function cm.check(c,e,tp,att)
	return rk.check(c,"RYUUHA") and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and c:IsAttribute(att)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(cm.spcheck,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.spcheck,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.check,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetAttribute())
		if g:GetCount()>0 then
			local rc=g:GetFirst()
			Duel.SpecialSummon(rc,0,tp,tp,true,true,POS_FACEUP)
			rc:CompleteProcedure()
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end
