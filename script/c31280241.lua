--再临的绝大
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--特殊召唤
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --手卡发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end    
function s.tgfilter(c)
	return c:IsAbleToGrave() and c:IsLevelBelow(5)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.spfilter(c)
	return c:IsXyzSummonable(nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil):Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    Duel.HintSelection(Group.FromCards(sc))
    local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
    if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and sc:IsLocation(LOCATION_GRAVE) 
    	and g:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,g)
    	if g:GetClassCount(Card.GetCode)==g:GetCount() and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
        	Duel.Recover(tp,800,REASON_EFFECT)		
		end
        Duel.ShuffleDeck(tp)        
	end        
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xacaa) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
    	and c:IsType(TYPE_XYZ)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) 
    	and c:IsAbleToDeck() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end	
function s.mtfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
    	and c:IsLocation(LOCATION_DECK) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 
        and tc:IsType(TYPE_XYZ) and not tc:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,nil,e) 
        and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
		if g:GetCount()>0 then
        	Duel.HintSelection(g)
        	Duel.Overlay(tc,g)
        end
	end        
end        
function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
    	and not Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil) 
end