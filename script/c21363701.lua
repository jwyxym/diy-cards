--江户之花价值千金
function c21363701.initial_effect(c) 
	aux.AddCodeList(c,21363700) 
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21363701+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c21363701.target)
	e1:SetOperation(c21363701.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F) 
	e2:SetCode(EVENT_REMOVE)
	e2:SetTarget(c21363701.settg)
	e2:SetOperation(c21363701.setop)
	c:RegisterEffect(e2)
end
function c21363701.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,21363700) and c:IsAbleToGrave()
end
function c21363701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363701.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c21363701.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(21363700)  
end 
function c21363701.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c21363701.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsCode(21363703) and Duel.IsExistingMatchingCard(c21363701.spfil,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21363701,0)) then
		local sg=Duel.SelectMatchingCard(tp,c21363701.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp) 
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) 
	end
end
function c21363701.setfilter(c)
	return aux.IsCodeListed(c,21363700) and not c:IsCode(21363701) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c21363701.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c21363701.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c21363701.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end


