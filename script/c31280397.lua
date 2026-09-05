--姦淫绝杰·瓦娜蕾格
local s,id,o=GetID()
function s.initial_effect(c)
	--融合召唤	
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x5ca1),2,true)
    c:EnableReviveLimit()
	--检测        
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(0xff)
	e0:SetOperation(s.adjustop)
	c:RegisterEffect(e0)
	--送去墓地    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.mztgcon)
	c:RegisterEffect(e2)
	--特殊召唤
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)    
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)   
    end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp) 	
	Duel.RegisterFlagEffect(ep,id,0,0,0)
    if Duel.GetTurnPlayer()==e:GetHandler():GetOwner() and Duel.IsMainPhase() then         
    	Duel.RegisterFlagEffect(ep,id+o,RESET_PHASE+PHASE_STANDBY,0,2)       
    end       	
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end    
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
    if Duel.GetFlagEffect(tp,id)>=7 then
    	for tc in aux.Next(g) do
        	tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
        end
    end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end    
function s.mztgcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==ep        
end
function s.tgfilter(c)
	return c:IsSetCard(0x5ca1) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and Duel.GetFlagEffect(tp,id)>=7
    	and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    	and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
    	Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if g:GetCount()>0 then
        	Duel.HintSelection(g)
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
	end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
    	local e1=Effect.CreateEffect(c)
    	e1:SetDescription(aux.Stringid(id,2))
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
    end    
end
function s.tdfilter(c)
	return c:IsSetCard(0x5ca1) and c:IsAbleToDeck() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c) 
    	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    if Duel.GetFlagEffect(tp,id+o)>0 then
    	e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
    	and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.NecroValleyFilter()(c)
        and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsFaceup() and Duel.GetFlagEffect(tp,id+o)>0 then
        Duel.BreakEffect()
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)        
	end
end