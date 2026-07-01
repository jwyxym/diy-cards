--魂契使者 美树沙耶香
function c38030121.initial_effect(c)
	--change name
	aux.EnableChangeCode(c,38030068,LOCATION_MZONE+LOCATION_GRAVE)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,38030068,38030070,true,true)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030121,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38030121)
	e1:SetCondition(c38030121.thcon)
	e1:SetTarget(c38030121.thtg)
	e1:SetOperation(c38030121.thop)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030121,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38030121+1)
	e2:SetTarget(c38030121.rectg)
	e2:SetOperation(c38030121.recop)
	c:RegisterEffect(e2)
end
function c38030121.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c38030121.thfilter(c)
	return c:IsSetCard(0x615) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c38030121.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030121.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030121.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38030121.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c38030121.recfilter(c)
	return c:IsFaceupEx() and c:GetBaseAttack()>0-- and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c38030121.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c38030121.recfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030121.recfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030121.recfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
end
function c38030121.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceupEx() and tc:GetBaseAttack()>0 then
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
