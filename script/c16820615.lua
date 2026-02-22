--救世游戏-猎人
local s,id,o=GetID()
function s.initial_effect(c)
	--放置
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--位置交换    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
    e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)    
end
function s.setfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xdf99) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=1<<e:GetHandler():GetSequence()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE,0,0,zone)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())    
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
    local zone=1<<c:GetSequence()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE,0,0,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then 
    	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone) 
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
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.desfilter(c,lg)
	return lg:IsContains(c)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local seq=c:GetSequence()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
    	Duel.SwapSequence(c,tc)
    	if c:GetSequence()==seq then return end
        local lg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,lg)
        if g:GetCount()>0 then
        	Duel.BreakEffect()
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
		end            
	end            
end