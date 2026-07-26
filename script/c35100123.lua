--异质绝望舞台-塔和
local m=35100123
local cm=_G["c"..m]
function cm.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(cm.spcon)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	--decrease atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(cm.eftg)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(m,4))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTarget(cm.optg)
	e8:SetCost(cm.tdcost2)
	e8:SetOperation(cm.opop)
	c:RegisterEffect(e8)
end
function cm.spfilter1(c,e,tp)
	return  c:IsSetCard(0xa91) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsLevelBelow(4)
end
function cm.cfilter1(c)
	return not (c:IsType(TYPE_TOKEN) or (c:IsSetCard(0xa91) and c:IsFaceup()))
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cm.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(m,5))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(cm.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			tc:RegisterEffect(e1,true)
	end
end
function cm.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
function cm.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xa91)
end
function cm.atkval(e)
	return Duel.GetMatchingGroupCount(cm.PD,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*100
end
function cm.PD(c)
	return c:IsSetCard(0xa91) and c:IsFaceup()
end

function cm.cfilter2(c)
	return c:IsFaceup() and (c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost()) and c:IsSetCard(0xa91)
end
function cm.tdcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cm.cfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cm.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsPlayerCanDraw(tp,1)
		and Duel.GetFlagEffect(tp,m)==0
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.GetFlagEffect(tp,m+1)==0
	if chk==0 then return b1 or b2 end
end
function cm.opop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35100145,0xa91,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35100145,0xa91,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) 
		and Duel.GetFlagEffect(tp,m)==0
	local b2=Duel.IsPlayerCanDiscardDeck(tp,4)
		and Duel.GetFlagEffect(tp,m+1)==0
	local op=0
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(m,1))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(m,2))+1
	else return end
	if op==0 then
		local token1=Duel.CreateToken(tp,35100145)
		local token2=Duel.CreateToken(tp,35100145)
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		Duel.SpecialSummonComplete()
		Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	else
		Duel.DiscardDeck(tp,4,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(m,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
			if g:GetCount()>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
		Duel.RegisterFlagEffect(tp,m+1,RESET_PHASE+PHASE_END,0,1)
	end
end
function cm.thfilter(c,tp)
	return c:IsSetCard(0xa91) and c:IsAbleToGrave()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end