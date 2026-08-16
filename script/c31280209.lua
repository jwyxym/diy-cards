--老牧师降临
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,true) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsType(TYPE_MONSTER)
    	and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e)
end
function s.ovfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.meqfilter(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,e:GetHandler()),tp)
end
function s.eqfilter(c,tp)
	return (c:IsControler(tp) or c:IsAbleToChangeControler()) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
    	and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsLocation(LOCATION_SZONE))
end
function s.penfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end    
function s.mvfilter(c,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(c:GetOwner()) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	return not c:IsForbidden() and c:CheckUniqueOnField(c:GetOwner()) and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE,tp,r)>0
end
function s.seqfilter(c)
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
end    
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)~=0 then
    	tc:CompleteProcedure()
        local b1=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
        local b2=Duel.IsExistingMatchingCard(s.meqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) 
        local b3=Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
        local b4=Duel.IsExistingMatchingCard(s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) 
        local b5=Duel.IsExistingMatchingCard(s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        local con=b1 or b2 or b3 or b4 or b5
        if con and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        	Duel.BreakEffect()
        	local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,2),1},
				{b2,aux.Stringid(id,3),2},
        		{b3,aux.Stringid(id,4),3},
                {b4,aux.Stringid(id,5),4},
        		{b5,aux.Stringid(id,6),5})
            if op==1 then
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            	local xc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
                local mg=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
                if xc and mg:GetCount()>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local xmg=mg:Select(tp,1,mg:GetCount(),nil)
                	if xmg:GetCount()>0 then
                    	Duel.HintSelection(Group.FromCards(xc))
						Duel.Overlay(xc,xmg)
                    end    
				end
            elseif op==2 then
            	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            	local mc=Duel.SelectMatchingCard(tp,s.meqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
                if mc then
                	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
					local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,Group.FromCards(mc,e:GetHandler()),tp):GetFirst()
                    if ec then
                    	Duel.HintSelection(Group.FromCards(ec,mc))
                        ec:CancelToGrave()
                    	if not Duel.Equip(tp,ec,mc) then return end
                    	local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_EQUIP_LIMIT)
						e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
						e1:SetLabelObject(mc)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						e1:SetValue(s.eqlimit)
						ec:RegisterEffect(e1)
                    end
                end   
            elseif op==3 then
            	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,7))
                local pc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
                if pc then
                	Duel.HintSelection(Group.FromCards(pc))
                    Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
                end
            elseif op==4 then
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
                local vc=Duel.SelectMatchingCard(tp,s.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
                if vc then
                	local vp=aux.SelectFromOptions(tp,
						{true,aux.Stringid(id,8),1},
						{true,aux.Stringid(id,9),2})
                    local type
                    if vp==1 then type=TYPE_SPELL+TYPE_CONTINUOUS
                    else type=TYPE_TRAP+TYPE_CONTINUOUS end
                	Duel.HintSelection(Group.FromCards(vc))
                    if vc:IsImmuneToEffect(e) or not Duel.MoveToField(vc,tp,vc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then return end
                    local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetCode(EFFECT_CHANGE_TYPE)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
					e2:SetValue(type)
					vc:RegisterEffect(e2)
                end
            elseif op==5 then
            	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,10))
				local qc=Duel.SelectMatchingCard(tp,s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
                if qc then
                	Duel.HintSelection(Group.FromCards(qc))
                    local p=tc:GetControler()
                    if qc:IsImmuneToEffect(e) or Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
                    local p1,p2
					if qc:IsControler(tp) then
						p1=LOCATION_MZONE
						p2=0
					else
						p1=0
						p2=LOCATION_MZONE
					end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
					local seq=math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)
					if qc:IsControler(1-tp) then seq=seq-16 end
					Duel.MoveSequence(qc,seq)                    
                end
            end    
        end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end