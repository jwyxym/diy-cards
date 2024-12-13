--涬溟龙 拉特朗多
function c21300516.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x674),2,3)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21300516)
	e1:SetCost(c21300516.spcost)
	e1:SetTarget(c21300516.sptg)
	e1:SetOperation(c21300516.spop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(21300516,ACTIVITY_SPSUMMON,c21300516.counterfilter)
	--cannot be link material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function c21300516.counterfilter(c)
	return c:IsSetCard(0x674)
end
function c21300516.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(21300516,tp,ACTIVITY_SPSUMMON)==0 end
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21300516.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c21300516.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x674)
end
function c21300516.filter(c,e)
	local seq=e:GetHandler():GetSequence()
	if seq<=4 then return false end
	return ((c:GetSequence()==0 or c:GetSequence()==1) and seq==5) or ((c:GetSequence()==2 or c:GetSequence()==3) and seq==6)
end
function c21300516.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x674) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c21300516.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21300516.spfilter(chkc,e,tp,zone) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c21300516.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	local a=Duel.GetMatchingGroupCount(c21300516.filter,tp,LOCATION_MZONE,0,nil,e)
	local b=1
	if e:GetHandler():GetSequence()>4 then b=b+1 end
	local d=b-a
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then d=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c21300516.spfilter,tp,LOCATION_GRAVE,0,1,d,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c21300516.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	local ct=g:GetCount()
	if ft>0 and ct<=ft and zone>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	if g:GetCount()>1 and not Duel.IsExistingMatchingCard(c21300516.filter1,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21300516,0)) then 
	local tc=g:GetFirst()
	while tc do
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	tc=g:GetNext()
	end
	end
	end
end
function c21300516.filter1(c)
	return not c:IsSetCard(0x674) and c:IsFaceup()
end