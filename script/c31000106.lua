--妖精骑士 布里托玛特 
function c31000106.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c31000106.lcheck)
	c:EnableReviveLimit()
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31000106,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31000106)
	e1:SetCondition(c31000106.spcon)
	e1:SetTarget(c31000106.sptg)
	e1:SetOperation(c31000106.spop)
	c:RegisterEffect(e1)
	--lvchange
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31000106,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31000106+1)
	e2:SetTarget(c31000106.lvtg)
	e2:SetOperation(c31000106.lvop)
	c:RegisterEffect(e2)
end
function c31000106.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WIND)
end
function c31000106.cfilter(c,lg)
	return (c:IsSetCard(0x311) or c:IsType(TYPE_XYZ)) and lg:IsContains(c)
end
function c31000106.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c31000106.cfilter,1,nil,lg)
end
function c31000106.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c31000106.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31000106.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c31000106.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31000106.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31000106.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000106.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c31000106.splimit(e,c)
	return not (c:IsSetCard(0x311) or c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
function c31000106.lvfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x311) and c:IsLevelAbove(1)
		and Duel.IsExistingMatchingCard(c31000106.lvfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function c31000106.lvfilter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
function c31000106.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31000106.lvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c31000106.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c31000106.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function c31000106.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sc=Duel.SelectMatchingCard(tp,c31000106.lvfilter2,tp,LOCATION_MZONE,0,1,1,tc,tc:GetLevel()):GetFirst()
		if sc then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000106.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end