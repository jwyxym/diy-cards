--唯我的一刀
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--回收
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.bdcon)
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
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and g:GetCount()>0 
    	and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then            	
        Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,g)
        if g:GetClassCount(Card.GetCode)==g:GetCount() then
            Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(0,1)
			e1:SetValue(s.aclimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
        end	
        Duel.ShuffleDeck(tp)
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and rc:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.bdfilter(c,e)
	return c:IsSetCard(0xacaa) and c:IsCanBeEffectTarget(e)
end    
function s.bhfilter(c,g)
	return c:IsAbleToHand() and g:IsExists(Card.IsAbleToDeck,1,c)
end
function s.fselect(g,mc)
	return g:IsExists(s.bhfilter,1,nil,g) and g:IsContains(mc)
end
function s.bdcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.bdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.bdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2,c) and c:IsCanBeEffectTarget(e) 
    	and (c:IsAbleToHand() or c:IsAbleToDeck()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,c)
	Duel.SetTargetCard(sg)    
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end    
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToEffect),nil,e)
    if g:GetCount()>0 then
    	local sg=g:Filter(Card.IsAbleToHand,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
        if Duel.SendtoHand(sc,nil,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_HAND) then
        	g:RemoveCard(sc)
			if g:GetCount()>0 then
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
            end
        end
    end    
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
    	and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil) 
end