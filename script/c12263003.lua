--天水 ：岛屿摇篮
function c12263003.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_LINK+TYPE_RITUAL),1,1)
	c:EnableReviveLimit()

	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12263003,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,12263003) -- 独立ID
	e1:SetCondition(c12263003.eqcon)
	e1:SetTarget(c12263003.eqtg)
	e1:SetOperation(c12263003.eqop)
	c:RegisterEffect(e1)

	--②效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12263003,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,122630031)
	e2:SetTarget(c12263003.sptg)
	e2:SetOperation(c12263003.spop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c12263003.descon)
	c:RegisterEffect(e3)
end

function c12263003.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c)
		return c:IsType(TYPE_LINK+TYPE_RITUAL) and c:IsFaceup()
	end,1,nil)
end

function c12263003.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsRelateToEffect(e)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function c12263003.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end

function c12263003.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp)
end

function c12263003.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(function(c,e,tp)
			return c:IsSetCard(0x5244) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function c12263003.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,function(c,e,tp)
		return c:IsSetCard(0x5244) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
