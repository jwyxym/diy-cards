--再临的绝大
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--补充超量素材
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.ovcon)
	e2:SetCost(s.ovcost)
	e2:SetTarget(s.ovtg)
	e2:SetOperation(s.ovop)
	c:RegisterEffect(e2)
    --手卡发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end    
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 
    	and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
end
function s.spfilter(c)
	return c:IsXyzSummonable(nil)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() then
    	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
		if rg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=rg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 
            	and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) 
                and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.BreakEffect()				              	
                local ct=Duel.RemoveOverlayCard(tp,1,0,1,2,REASON_EFFECT)
                local cg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
                local b1=ct>0 and Duel.IsPlayerCanDraw(tp,ct)
                local b2=cg:GetCount()>0
               	local off=1
				local ops={}
				local opval={}
                if b1 then
					ops[off]=aux.Stringid(id,4)
					opval[off-1]=1
					off=off+1
				end
				if b2 then
					ops[off]=aux.Stringid(id,5)
					opval[off-1]=2
					off=off+1
				end
                local op=Duel.SelectOption(tp,table.unpack(ops))
				if opval[op]==1 then
                    Duel.BreakEffect()
					Duel.Draw(tp,ct,REASON_EFFECT)
				elseif opval[op]==2 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tg=cg:Select(tp,1,1,nil)
					Duel.XyzSummon(tp,tg:GetFirst(),nil)                  
				end    
			end
		end        
	end        
end
function s.ovfilter(c,e)
	return c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e)) and c:IsSetCard(0xacaa)
end        
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0xacaa) and c:IsType(TYPE_XYZ)
end
function s.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e)
		local tc=g:GetFirst()
		if tc then
			Duel.Overlay(c,tc)
		end
		Duel.ShuffleDeck(tp)
	end
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
    	and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil) 
end