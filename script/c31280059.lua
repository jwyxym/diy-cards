--至高的凌驾
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.bdtg)
	e2:SetOperation(s.bdop)
	c:RegisterEffect(e2)
	 --手卡发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    local ch=Duel.GetCurrentChain()
    local te,tep=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if ch>1 and tep==1-tp and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
    else
    	e:SetCategory(CATEGORY_TODECK)    
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    if dg:GetCount()<=0 then return end
    	Duel.HintSelection(dg)
    	if Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)~=0 then
    	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
        local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
        local res=true
        if oc>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        	Duel.BreakEffect()
        	Duel.ConfirmCards(1-tp,g)
            if g:GetClassCount(Card.GetCode)==g:GetCount() then
            	res=false
        		local ch=Duel.GetCurrentChain()
        		local te,tep=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
        		local con=ch>1 and tep==1-tp and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
        			and Duel.IsChainDisablable(ch-1)
                local op=aux.SelectFromOptions(tp,
					{true,aux.Stringid(id,4),1},
					{con,aux.Stringid(id,5),2})
        		if op==1 then
                	local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD)
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e1:SetCode(EFFECT_DRAW_COUNT)
					e1:SetTargetRange(1,0)
					e1:SetValue(s.drval)
                    if Duel.GetTurnPlayer()==tp then
						e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
					else
						e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
					end
					Duel.RegisterEffect(e1,tp)
                elseif op==2 then                	
                	if Duel.NegateEffect(ch-1) and te:GetHandler():IsRelateToEffect(te) then
                    	Duel.Destroy(te:GetHandler(),REASON_EFFECT)
                    end
                end
			end
        	if res then
        		Duel.ShuffleDeck(tp)
           	end                                 
		end                
	end                
end 
function s.drfilter(c)
	return c:GetType()&0x7
end        
function s.drval(e)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,nil)
	return g:GetClassCount(s.drfilter)
end
function s.bdfilter(c)
	return c:IsSetCard(0xacaa) and c:IsAbleToDeck()
end
function s.bdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.bdfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.bdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.bdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,c)
	Duel.SetTargetCard(c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToEffect),nil,e)
    if sg:GetCount()>0 then
    	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
    end
end    
function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
    	and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil) 
end