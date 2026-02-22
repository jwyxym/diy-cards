--救世游戏-医师
local s,id,o=GetID()
function s.initial_effect(c)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)  
	--特殊召唤    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.dspcon)
    e2:SetCost(s.dspcost)
	e2:SetTarget(s.dsptg)
	e2:SetOperation(s.dspop)
	c:RegisterEffect(e2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.mvfilter(c,lg)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	return ((seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))) 
        and lg:IsContains(c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
    	local lg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
    	local g=Duel.GetMatchingGroup(s.mvfilter,tp,0,LOCATION_MZONE,nil,lg)
        if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
        	local sg=g:Select(tp,1,1,nil)
            local sc=sg:GetFirst()
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			if seq>0 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1))<<16 end
			if seq<4 and Duel.CheckLocation(1-tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1))<<16 end
			if flag==0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,~flag)>>16
			local nseq=math.log(s,2)
			Duel.HintSelection(sg)
			Duel.MoveSequence(sc,nseq)
        end
	end
end
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
function s.rlfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function s.dspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.rlfilter,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,s.rlfilter,1,1,e:GetHandler(),tp)
	Duel.Release(g,REASON_COST)
end
function s.dspfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xdf99)
end
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end