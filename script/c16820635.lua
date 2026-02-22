--救世游戏-代码修复员
local s,id,o=GetID()
function s.initial_effect(c)
	--融合召唤
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf99),2,true)
	--特殊召唤    
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--位置交换    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_MSET+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)    
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xdf99)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
    	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
     end   
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()<5
end 
function s.chfilter(c,tp)
	return c:IsSetCard(0xdf99) and not c:IsCode(id) and c:IsFaceup() and c:GetSequence()<5
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.chfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.chfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sg=Duel.SelectTarget(tp,s.chfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disfilter(c,lg)
	return lg:IsContains(c) and aux.NegateMonsterFilter(c) and c:IsCanTurnSet()
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local seq=c:GetSequence()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
    	Duel.SwapSequence(c,tc)
    	if c:GetSequence()==seq then return end
        local lg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
        local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_MZONE,nil,lg)
        if g:GetCount()>0 then
        	Duel.BreakEffect()
            for sc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				sc:RegisterEffect(e2)
                if sc:IsType(TYPE_TRAPMONSTER) then
					local e3=e1:Clone()
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					sc:RegisterEffect(e3)
				end
        		Duel.AdjustInstantly()
				Duel.NegateRelatedChain(sc,RESET_CHAIN)
        		Duel.ChangePosition(sc,POS_FACEDOWN_DEFENSE)
            end    
        end
	end        
end