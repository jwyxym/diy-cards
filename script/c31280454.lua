--疯狂药剂师-枯萎者
local s,id,o=GetID()
function s.initial_effect(c)
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
	--适用效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.efcon)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)     
	--移动计数    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_MOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)        
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
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
    e1:SetDescription(aux.Stringid(id,6))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
function s.bhfilter(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp) and  (c:IsAbleToHand() or c:IsAbleToExtra())
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local p=c:GetControler()
    local seq=c:GetSequence()
    local zseq=aux.MZoneSequence(seq)
    local zone=4-zseq    
    local hg=Duel.GetMatchingGroup(s.bhfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,p)
	local b1=Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0)>0 
    local b2=c:IsControlerCanBeChanged() and Duel.CheckLocation(1-p,LOCATION_MZONE,zone)
    local b3=c:GetFlagEffect(id)>0 and hg:GetCount()>0 and c:IsAbleToHand()
	if chk==0 then return (b1 or b2 or b3) end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()    
	for i=1,5 do
    	local p=c:GetControler()
    	local seq=c:GetSequence()
    	local zseq=aux.MZoneSequence(seq)
    	local zone=4-zseq      
    	local hg=Duel.GetMatchingGroup(s.bhfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,c:GetControler())
		local b1=c:IsRelateToEffect(e) and Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0)>0
        	and not c:IsImmuneToEffect(e)
    	local b2=c:IsRelateToEffect(e) and c:IsControlerCanBeChanged() and Duel.CheckLocation(1-p,LOCATION_MZONE,zone)
    	local b3=c:GetFlagEffect(id)>0 and hg:GetCount()>0 and c:IsAbleToHand()
        local b4=i>1
		if not b1 and not b2 and not b3 then break end
        local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2},
			{b3,aux.Stringid(id,4),3},
			{b4,aux.Stringid(id,5),4})
		if i>1 and op~=4 then
			Duel.BreakEffect()
		end
        if op==1 then
        	local loc1,loc2
			if c:IsControler(tp) then
				loc1=LOCATION_MZONE
				loc2=0
			else
				loc1=0
				loc2=LOCATION_MZONE
			end
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local fd=Duel.SelectDisableField(tp,1,loc1,loc2,0)
			Duel.Hint(HINT_ZONE,tp,fd)
			local sseq=math.log(fd,2)			
            if c:IsControler(1-tp) then sseq=sseq-16 end
			Duel.MoveSequence(c,sseq)
        elseif op==2 then                	
        	Duel.GetControl(c,1-p,0,0,1<<zone)           
        elseif op==3 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
            local hc=hg:Select(tp,1,1,nil):GetFirst()
            Duel.HintSelection(Group.FromCards(hc))                   
            if Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) 
            	and c:IsRelateToEffect(e) then
                Duel.BreakEffect()
                Duel.SendtoHand(c,nil,REASON_EFFECT)
            end        	
        elseif op==4 then
			break
		end
    end    
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
        and c:IsFaceup() and c:IsPreviousPosition(POS_FACEUP)
end    
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end