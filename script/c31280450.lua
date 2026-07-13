--猎装双刀之技：空中回旋乱舞
local s,id,o=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
    aux.AddCodeList(c,31280444)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.bhtg)
	e1:SetOperation(s.bhop)
	c:RegisterEffect(e1)
	--盖放回合发动
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
function s.bhfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsFaceup() and c:IsAbleToHand()
end
function s.bhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bhfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.desfilter(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp)
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local hc=Duel.SelectMatchingCard(tp,s.bhfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
    if not hc then return end
    Duel.HintSelection(Group.FromCards(hc))
	if Duel.SendtoHand(hc,tp,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) and hc:IsControler(tp) then
		Duel.ConfirmCards(1-tp,hc)
        if hc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
        	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
            Duel.ShuffleHand(tp)
            if Duel.SpecialSummon(hc,0,tp,1-tp,true,false,POS_FACEUP)~=0 and hc:IsControler(1-tp) then
            	hc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
                local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_END)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCountLimit(1)
                e1:SetLabelObject(hc)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
            	local ct=2
                if hc:IsCode(31280444) then ct=4 end
                for i=1,ct do                               
            		local seq=hc:GetSequence()                  
                    local tg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,hc:GetControler())                               
                    if tg:GetCount()<=0 then break end                   
                    if i>1 then
                    	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then 
							Duel.BreakEffect()
                        else break end    
					end
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                    local dc=tg:Select(tp,1,1,nil):GetFirst()
                    Duel.HintSelection(Group.FromCards(dc))
                    local sseq=dc:GetSequence()
                    if Duel.Destroy(dc,REASON_EFFECT)~=0 and Duel.MoveSequence(hc,sseq) then
                    	if hc:GetSequence()~=sseq then break end
                    end
                end	
            end
        end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(tc)
	e1:SetTarget(s.rettg)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.reset)
	Duel.RegisterEffect(e2,tp)
end
function s.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(id)~=0
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	local tc=e1:GetLabelObject()
	tc:ResetFlagEffect(id)
	e1:Reset()
	e:Reset()
end
function s.actfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsFaceup()
end
function s.actcon(e)
	return Duel.GetMatchingGroupCount(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>0
end