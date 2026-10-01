--圣浊的裁断
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCondition(s.bhcon)
	e1:SetTarget(s.bhtg)
	e1:SetOperation(s.bhop)
	c:RegisterEffect(e1)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6ce1)
end
function s.bhcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.bhfilter(c)
	return c:IsAbleToHand() and c:IsLevelAbove(1) and c:IsFaceup()
end
function s.fselect(g)
	return g:GetSum(Card.GetLevel)==3 or g:GetSum(Card.GetLevel)==5 or g:GetSum(Card.GetLevel)==7
    	or g:GetSum(Card.GetLevel)==11
end
function s.gcheck(g)
	return g:GetSum(Card.GetLevel)<=3 or g:GetSum(Card.GetLevel)<=5 or g:GetSum(Card.GetLevel)<=7
    	or g:GetSum(Card.GetLevel)<=11
end
function s.bhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.bhfilter,tp,0,LOCATION_MZONE,nil)
    aux.GCheckAdditional=s.gcheck
	if chk==0 then
    	local res=g:CheckSubGroup(s.fselect,1,g:GetCount())
		aux.GCheckAdditional=nil
    	return res or Duel.IsExistingMatchingCard(Card.IsReleasable,tp,0,LOCATION_MZONE,1,nil)
    end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.bhfilter,tp,0,LOCATION_MZONE,nil)
    local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
    local res=g:CheckSubGroup(s.fselect,1,g:GetCount())
    aux.GCheckAdditional=s.gcheck
    if res then
    	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)
		local sg=g:SelectSubGroup(1-tp,s.fselect,false,1,g:GetCount())
		aux.GCheckAdditional=nil
        if sg and sg:GetCount()>0 then
        	Duel.HintSelection(sg)
			Duel.SendtoHand(sg,nil,REASON_RULE)
		end
    else
    	if rg:GetCount()>0 then
    		Duel.Release(rg,REASON_RULE)
        end
    end
end