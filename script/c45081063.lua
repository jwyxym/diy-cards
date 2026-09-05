--超重力场
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,98875864)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x186) end)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTarget(function(e,c) return c:GetMutualLinkedGroupCount()>0 end)
	e3:SetValue(200)
	c:RegisterEffect(e3)
	--Add 1 monster "G Golem" from your Deck to your hand, then discard 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.thfilter(c)
	return c:IsSetCard(0x186) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.ddfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x186) and c:IsType(TYPE_LINK)
		and Duel.GetMZoneCount(tp,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ddfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ddfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.IsPlayerCanSpecialSummonMonster(tp,98875864,0x186,TYPES_TOKEN_MONSTER,0,0,3,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.ddfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	local ct=tc:GetLink()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,98875864,0x186,TYPES_TOKEN_MONSTER,0,0,3,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		local count=math.min(ft,ct)
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(85243784,1))
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			local token=Duel.CreateToken(tp,98875864)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			count=count-1
		until count==0
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE)
end