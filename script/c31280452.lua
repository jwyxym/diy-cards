--猎装逐火
local s,id,o=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--给与伤害
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
    e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--盖放回合发动
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)        
end
function s.rmfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if Duel.Remove(tc,0,REASON_COST+REASON_TEMPORARY)~=0 then
    	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
        e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
    end
	e:SetLabelObject(tc)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0 and re:GetHandler()==e:GetHandler()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
    e:GetLabelObject():RegisterFlagEffect(31280445,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp and 1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,500)
end
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp)
end    
function s.ggfilter(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp)
end
function s.disfilter(c,tp)
	return aux.NegateAnyFilter(c) and c:IsOnField() and c:IsControler(1-tp)
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.Damage(1-tp,500,REASON_EFFECT,true) or not Duel.Damage(tp,500,REASON_EFFECT,true) then return end
	Duel.RDComplete()
    local tc=e:GetLabelObject()
    if tc:IsLocation(LOCATION_MZONE) and tc:GetFlagEffect(31280445)~=0 then
    	tc:ResetFlagEffect(31280445)
    	local atr=tc:GetAttribute()
        local lg=tc:GetColumnGroup()
        local res=false
        local b1=atr==ATTRIBUTE_LIGHT and lg:IsExists(s.tgfilter,1,nil,tp)
        local b2=atr==ATTRIBUTE_FIRE and lg:IsExists(s.disfilter,1,nil,tp)
        if (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    		if b1 then
            	local tg=lg:Filter(s.tgfilter,nil,tp)
                local sg=Group.CreateGroup()
            	local gg=Group.CreateGroup()
        		if tg:GetCount()>0 then
                	for tc in aux.Next(tg) do
                    	local seq=tc:GetSequence()
                        gg=Duel.GetMatchingGroup(s.ggfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,tc:GetControler()) 
                        Group.Merge(sg,gg)
        			end
                    Group.Merge(sg,tg)	
                end                
                res=Duel.SendtoGrave(sg,REASON_EFFECT)                
        	end
        	if b2 then
            	if res then Duel.BreakEffect() end
            	local dg=lg:Filter(s.disfilter,nil,tp)
                local c=e:GetHandler()
                for dc in aux.Next(dg) do
					Duel.NegateRelatedChain(dc,RESET_TURN_SET)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					dc:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					dc:RegisterEffect(e2)
					if dc:IsType(TYPE_TRAPMONSTER) then
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
						e3:SetReset(RESET_EVENT+RESETS_STANDARD)
						dc:RegisterEffect(e3)
					end
				end
        	end
        end
    end
end
function s.actfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsFaceup()
end
function s.actcon(e)
	return Duel.GetMatchingGroupCount(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>0
end