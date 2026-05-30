--飞向未来
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.atkfilter(c)
	return not (c:IsAttack(0) and c:IsDefense(0)) and c:IsFaceup()
end    
function s.bhfilter(c)
	return (c:IsAbleToHand() or c:IsAbleToExtra())
end    
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroupCount(s.atkfilter,tp,0,LOCATION_MZONE,nil)>=2
    local b2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):FilterCount(s.bhfilter,nil)>0
	if chk==0 then return (b1 or b2) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
    if op==1 then
    	e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    elseif op==2 then
    	e:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DRAW)
    	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
        Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,1-tp,LOCATION_ONFIELD)
    end	
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(re,rp,tp)
	return tp==rp or not re:GetHandler():IsType(TYPE_MONSTER) or re:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	if op==1 then
    	local ag=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
        if ag:GetCount()<2 then return end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sg=ag:Select(tp,2,2,nil)
        Duel.HintSelection(sg)
        local g=Group.CreateGroup()
        for tc in aux.Next(sg) do
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
            local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e2)
            Duel.AdjustAll()
            local atk=tc:GetAttack()
            local def=tc:GetDefense()
            if (atk<=0 or def<=0) then
            	g:AddCard(tc)
            end
        end
        if g:GetCount()>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 
        	and Duel.GetDecktopGroup(tp,5):FilterCount(Card.IsAbleToHand,nil)>0
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        	Duel.BreakEffect()
            Duel.ConfirmDecktop(tp,5)
			local dg=Duel.GetDecktopGroup(tp,5)
            if dg:GetCount()>0 then
            	local tg=dg:Filter(s.thfilter,nil)
				if tg:GetCount()>1 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local hg=tg:Select(tp,2,2,nil)
					Duel.SendtoHand(hg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,hg)
				end
				Duel.ShuffleDeck(tp)
            end
        end
    elseif op==2 then
    	local bg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(s.bhfilter,nil)
        if bg:GetCount()>0 then
    		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
            local hc=bg:Select(tp,1,1,nil):GetFirst()
            Duel.HintSelection(Group.FromCards(hc))
            if Duel.SendtoHand(hc,nil,REASON_RULE,1-tp)~=0 and hc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
            	and Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)>=2
                and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            	Duel.BreakEffect()
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            	local og=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
                if og:GetCount()<1 then return end
                Duel.HintSelection(og)
                if Duel.SendtoDeck(og,nil,2,REASON_EFFECT)~=0 then
                	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
                    if oc<=0 then return end
                    Duel.BreakEffect()
                    Duel.ShuffleDeck(tp)
                    Duel.Draw(tp,1,REASON_EFFECT)
                end
            end
        end
    end
end