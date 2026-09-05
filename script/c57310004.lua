--人性的爱
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57310005)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+id)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<2 then return false end
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local sg=Group.CreateGroup()
	for i=1,2 do
		local token=Duel.CreateToken(tp,57310005)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			sg:AddCard(token)
		end
	end
	if #sg>0 then
		Duel.SpecialSummonComplete()
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.extlimit)
	Duel.RegisterEffect(e1,tp)
end
function s.extlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return s.sefi_filter(chkc)
			and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
			and chkc:IsControler(tp)
	end
	if chk==0 then
		return e:GetHandler():IsAbleToHand()
			and Duel.IsExistingTarget(s.sefi_filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.sefi_filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end

function s.sefi_filter(c)
	return c:IsCode(57310001) and c:IsFaceupEx()
		and c:IsAbleToHand()
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)~=0 then
	if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	local g1=Group.FromCards(c,tc)
	if #g1==2 then
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
	end
end