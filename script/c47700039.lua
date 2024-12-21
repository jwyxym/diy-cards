--炫幻灵摆
function c47700039.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetTarget(c47700039.tgtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47700039)
	e2:SetCondition(c47700039.thcon)
	e2:SetTarget(c47700039.thtg)
	e2:SetOperation(c47700039.thop)
	c:RegisterEffect(e2)
end
function c47700039.tgtg(e,c)
	return c:IsSetCard(0x470)
end
function c47700039.thcfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousSetCard(0x470)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_PZONE)
end
function c47700039.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47700039.thcfilter,1,nil,tp)
end
function c47700039.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x470) and c:IsAbleToHand() and c:IsFaceupEx()
end
function c47700039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c47700039.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c47700039.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c47700039.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end