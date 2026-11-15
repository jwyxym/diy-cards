-- 神葬零娘 裂界终深
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,94380860,20785975)


	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- ① 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.protect_filter)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	-- ① 
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD)
	e3x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3x:SetRange(LOCATION_SZONE)
	e3x:SetTargetRange(LOCATION_MZONE,0)
	e3x:SetTarget(s.protect_filter)
	e3x:SetValue(s.indesval)
	c:RegisterEffect(e3x)

	-- ② 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)

	-- ③ 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end

-- ============================================================


function s.protect_filter(e,c)
	return c:IsFaceup() and (c:IsCode(94380860) or c:IsCode(20785975))
end


function s.indesval(e,re,r,rp)
	return re and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
end

-- ============================================================


function s.thfilter(c)
	return c:IsAbleToHand() and (
		c:IsCode(20785975)
		or c:IsCode(94380860)
		or aux.IsCodeListed(c,94380860)
	)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter),
		tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ============================================================


function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.atkfilter(c)
	return c:IsFaceup() and (
		c:IsCode(94380860) or c:IsCode(20785975)
		or aux.IsCodeListed(c,94380860)
	)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsControler(tp) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end