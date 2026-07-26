--颠魔武者-鬼武士
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xca0)
	--特召规则
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
    e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	--放置指示物   
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--取除指示物
   	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)          
end
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_MONSTER)
end
function s.sprcon(e,c)
	if c==nil then return true end
    local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==4
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.ctfilter,nil)
	if ct>0 and e:GetHandler():IsCanAddCounter(0xca0,ct) then
    	Duel.Hint(HINT_CARD,0,id)
		e:GetHandler():AddCounter(0xca0,ct)
	end
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0xca0)>0 and c:IsControlerCanBeChanged() 
    	and Duel.GetMatchingGroupCount(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)>0 end
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.tgfilter(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp) and c:IsAbleToGrave()
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local ct=c:GetCounter(0xca0)
	if c:IsRelateToEffect(e) and c:RemoveCounter(tp,0xca0,ct,REASON_EFFECT)~=0
    	and Duel.GetControl(c,1-tp)~=0 and c:IsControler(1-tp) then
        local res=false
    	for i=1,ct do
        	local seq=c:GetSequence()                  
            local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,c:GetControler())                               
            if tg:GetCount()<=0 or c:IsImmuneToEffect(e) then break end                   
            if i>1 then
            	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then 
					Duel.BreakEffect()
                else break end    
			end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tc=tg:Select(tp,1,1,nil):GetFirst()
            Duel.HintSelection(Group.FromCards(tc))
            local sseq=tc:GetSequence()
           	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) 
               	and Duel.MoveSequence(c,sseq) then
                if hc:GetSequence()~=sseq then break end                
            end
           	res=true         
        end
        if res and c:IsLocation(LOCATION_MZONE) then
        	Duel.BreakEffect()
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    end
end