--滓溟引导者
function c21300502.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21300502+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21300502.spcon)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21300503)
	e2:SetCondition(c21300502.thcon)
	e2:SetTarget(c21300502.thtg)
	e2:SetOperation(c21300502.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function c21300502.spfilter(c)
	return not c:IsSetCard(0x674) and c:IsFaceup()
end
function c21300502.spcon(e,c)
	if c==nil then return true end
	return (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c21300502.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil))
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c21300502.cfilter(c,tp)
	return c:IsSetCard(0x674) and c:IsControler(tp) and c:IsFaceup()
end
function c21300502.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21300502.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function c21300502.thfilter(c)
	return c:IsSetCard(0x674) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c21300502.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21300502.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21300502.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21300502.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
