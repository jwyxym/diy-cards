--乐园巡礼 阿尔托莉雅·卡斯特
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,99,this.check)
	c:EnableReviveLimit()
	aux.AddCodeList(c,76200312)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	e4:SetCondition(this.thcon)
	e4:SetTarget(this.thtg)
	e4:SetOperation(this.thop)
	c:RegisterEffect(e4)
	aux.EnableChangeCode(c,76200312,LOCATION_ONFIELD+LOCATION_GRAVE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(this.cost)
	e1:SetTarget(this.tg)
	e1:SetOperation(this.op)
	c:RegisterEffect(e1)
end
function this.check(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM)
end
function this.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function this.thfilter(c,tp)
	return c:IsSetCard(0x723) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function this.filter(c,e,tp)
	local r=c:GetOriginalRace()
	return r&RACE_SPELLCASTER~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0
	or r&RACE_SPELLCASTER==0 and c:IsDestructable()
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function this.tg(e,tp,eg,ep,ev,re,reason,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,this.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp):GetFirst()
	local r=tc:GetOriginalRace()
	e:SetLabel(r)
	if r&RACE_SPELLCASTER then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_PZONE)
	else
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end
function this.op(e,tp,eg,ep,ev,re,reason,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local r=e:GetLabel()
	if r&RACE_SPELLCASTER~=0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
	   if Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	   end
	end
end
