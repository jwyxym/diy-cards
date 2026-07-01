--墨染乐章 薄叶
function c21301006.initial_effect(c) 
	--sre
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21301006) 
	e1:SetTarget(c21301006.sretg)
	e1:SetOperation(c21301006.sreop)
	c:RegisterEffect(e1) 
	--sp 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21301007)
	e1:SetTarget(c21301006.sptg)
	e1:SetOperation(c21301006.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)  
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE) 
	c:RegisterEffect(e2)  
	c21301006.remove_effect=e2  
end
function c21301006.spfilter(c,e,tp)
	return c:IsSetCard(0x682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function c21301006.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301006.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c21301006.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c21301006.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
	end
end
function c21301006.srefil(c,e,tp) 
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToRemove()
	local b2=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsAbleToRemove()
	return c:IsSetCard(0x682) and (b1 or b2)
end 
function c21301006.sretg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c21301006.srefil,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end 
	local tc=Duel.SelectMatchingCard(tp,c21301006.srefil,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp):GetFirst() 
	e:SetLabelObject(tc) 
	Duel.SetTargetCard(tc)
	local sg=Group.FromCards(tc,e:GetHandler()) 
	Duel.ConfirmCards(1-tp,sg) 
	Duel.ShuffleHand(tp)  
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND) 
end
function c21301006.sreop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=e:GetLabelObject() 
	if not c:IsRelateToEffect(e) then return end 
	if not tc:IsRelateToEffect(e) then return end 
	local g=Group.CreateGroup()
	local b1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToRemove()
	local b2=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsAbleToRemove()
	if b1 then g:AddCard(tc) end 
	if b2 then g:AddCard(c) end   
	local sc=g:Select(tp,1,1,nil):GetFirst()  
	local xg=Group.FromCards(c,tc)
	local rc=xg:Filter(aux.TRUE,sc):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 and rc then  
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end