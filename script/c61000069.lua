--混沌之终黯 加拉哈德
local s,id,o=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.NonTuner(nil),1,99,s.syncheck)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1102)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
end
function s.syfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) 
	and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,2)
end
function s.levlcheck1(c)
	local raw_level=c:GetLevel()
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function s.levelcheck2(g,lv)
	return g:GetSum(Card.GetLevel)==lv
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.syfilter(c,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.syfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp,s.syfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lv=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,tc)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.levelcheck2,false,2,2,lv)
	if #sg==2 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==#sg 
		and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e1,true)
		end
	end
end
function s.syncheck(g)
	return g:GetClassCount(Card.GetOriginalRace)==#g or g:GetClassCount(Card.GetOriginalAttribute)==#g
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_SYNCHRO) then
		local g=c:GetMaterial()
		if g:GetClassCount(Card.GetRace)==#g and g:GetClassCount(Card.GetAttribute)==#g then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end
function s.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToRemove()) and c:IsCanBeEffectTarget(e)
end
function s.check(g)
	return g:IsExists(s.thfiter2,1,nil,g)
end
function s.thfiter2(c,g)
	return c:IsAbleToHand() and g:IsExists(Card.IsAbleToRemove,1,c)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.check,2,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:SelectSubGroup(tp,s.check,false,2,2)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetsRelateToChain()
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=sg:FilterSelect(tp,s.thfiter2,1,1,nil,sg)
		sg:Sub(g1)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end