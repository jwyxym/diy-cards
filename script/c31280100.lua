--科尔努诺丝
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--抽卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--特殊召唤
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10000)
    e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)   
end
function s.thfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.tgfilter(c,tp)
	local b1=Duel.IsPlayerCanDraw(tp,1)
    local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
    	and aux.IsCodeListed(c,31280102)
	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
    	and (b1 or b2)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp) end
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		if aux.IsCodeListed(tc,31280102) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
        	and (not Duel.IsPlayerCanDraw(tp,1) or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
        else
			Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and c:IsType(TYPE_FUSION)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end