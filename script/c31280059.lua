--至高的凌驾
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--回到手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,5))
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	 --手卡发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
function s.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    local ch=Duel.GetCurrentChain()
    local te,tep=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if ch>1 and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DISABLE)
    else
    	e:SetCategory(CATEGORY_TODECK)    
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
    Duel.DisableShuffleCheck()
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)    
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    local gt=Duel.GetCurrentChain()
    if gt<2 then Duel.ShuffleDeck(tp) end
	if ct>0 and gt>=2 then
		local te,tep=Duel.GetChainInfo(gt-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
        	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then Duel.ShuffleDeck(tp)
            else
        		local fg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
				if fg:GetCount()<1 then return end
        		Duel.BreakEffect()
				Duel.ConfirmCards(1-tp,fg)
            	Duel.ShuffleDeck(tp)
        		if fg:GetClassCount(Card.GetCode)==fg:GetCount() then
            		Duel.BreakEffect()				              	
                	local b1=Duel.IsPlayerCanDraw(tp,1)
                	local b2=Duel.IsChainDisablable(gt-1)
               		local off=1
					local ops={}
					local opval={}
                	if b1 then
						ops[off]=aux.Stringid(id,2)
						opval[off-1]=1
						off=off+1
					end
					if b2 then
						ops[off]=aux.Stringid(id,3)
						opval[off-1]=2
						off=off+1
					end
                	local op=Duel.SelectOption(tp,table.unpack(ops))
					if opval[op]==1 then
                    	Duel.BreakEffect()
						Duel.Draw(tp,1,REASON_EFFECT)
					elseif opval[op]==2 then
						Duel.BreakEffect()  
                   	 	Duel.NegateEffect(gt-1)
                    end                     
                end
			end            
		end            
	end    
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0xacaa) and c:IsType(TYPE_XYZ)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
    	and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil) 
end