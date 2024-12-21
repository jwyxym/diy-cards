--虚空结构·漩涡
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(0xff)
	e0:SetOperation(s.adjustop)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--flag
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(81096431)
	e2:SetValue(id)
	e2:SetRange(0xff)
	e2:SetTarget(s.sxyzfilter)
	e2:SetCountLimit(99,id+o)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local c=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK))
end
function s.sxyzfilter(e,c)
	return c:IsRace(RACE_MACHINE)
end
function s.Drake_shark_f(function_f,int_lv,card_c)
	return function (c)
			   return c:IsXyzLevel(card_c,int_lv) and (not function_f or function_f(c))
	end
end
function s.sxfilter(c,tp,xc,eid)
	local te=c:IsHasEffect(81096431,tp)
	if te and te:GetValue()==eid then
		local etg=te:GetTarget()
		return etg(te,xc)
	end
end
function s.Drake_shark_gf(int_ct,int_tp,xc)
	return function (g)
			   local ct=g:GetCount()
			   if g:IsExists(s.sxfilter,1,nil,int_tp,xc,81096431) then
				   ct=ct+1
			   end
			   if g:IsExists(s.sxfilter,1,nil,int_tp,xc,id) then
				   ct=ct+1
			   end
			   return ct>=int_ct
	end
end
function s.xfilter(c,tp)
	return c:IsHasEffect(81096431,tp)
end
function s.eftfilter(c,tp)
	local te=c:IsHasEffect(81096431,tp)
	return te:GetValue()
end
function s.gcheck(g,tp)
	return g:GetClassCount(s.eftfilter,tp)==g:GetCount()
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0,81096431)==0 then
		Duel.RegisterFlagEffect(0,81096431,0,0,1)
		Drake_shark_AddXyzProcedure=aux.AddXyzProcedure
		function aux.AddXyzProcedure(card_c,function_f,int_lv,int_ct,function_alterf,int_dese,int_maxc,function_op)
			if int_ct>=3 then
				if function_alterf then
					Drake_shark_XyzLevelFreeOperationAlter=Auxiliary.XyzLevelFreeOperationAlter
					function Auxiliary.XyzLevelFreeOperationAlter(f,gf,minc,maxc,alterf,alterdesc,alterop)
						return  function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
									if og and not min then
										if og:GetCount()<maxc and mg:GetCount()>=minc and maxc==minc+2 then
											local et=maxc-og:GetCount()
											local exg=og:Filter(Card.IsHasEffect,nil,81096431,tp)
											local ext=exg:GetClassCount(s.eftfilter,tp)
											if et==0 or 2-et==ext then
												for ttc in aux.Next(og) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											else
												local st=2-et
												Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81096431,3))
												local reg=exg:SelectSubGroup(tp,s.gcheck,false,st,st,tp)
												for ttc in aux.Next(reg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											end
										end
										local sg=Group.CreateGroup()
										local tc=og:GetFirst()
										while tc do
											local sg1=tc:GetOverlayGroup()
											sg:Merge(sg1)
											tc=og:GetNext()
										end
										Duel.SendtoGrave(sg,REASON_RULE)
										c:SetMaterial(og)
										Duel.Overlay(c,og)
									else
										local mg=e:GetLabelObject()
										if mg:GetCount()<maxc and mg:GetCount()>=minc and maxc==minc+2 then
											local et=maxc-mg:GetCount()
											local exg=mg:Filter(Card.IsHasEffect,nil,81096431,tp)
											local ext=exg:GetClassCount(s.eftfilter,tp)
											if et==0 or 2-et==ext then
												for ttc in aux.Next(exg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											else
												local st=2-et
												Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81096431,3))
												local reg=exg:SelectSubGroup(tp,s.gcheck,false,st,st,tp)
												for ttc in aux.Next(reg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											end
										end
										if e:GetLabel()==1 then
											local mg2=mg:GetFirst():GetOverlayGroup()
											if mg2:GetCount()~=0 then
												Duel.Overlay(c,mg2)
											end
										else
											local sg=Group.CreateGroup()
											local tc=mg:GetFirst()
											while tc do
												local sg1=tc:GetOverlayGroup()
												sg:Merge(sg1)
												tc=mg:GetNext()
											end
											Duel.SendtoGrave(sg,REASON_RULE)
										end
										c:SetMaterial(mg)
										Duel.Overlay(c,mg)
										mg:DeleteGroup()
									end
								end
					end
					aux.AddXyzProcedureLevelFree(card_c,s.Drake_shark_f(function_f,int_lv,card_c),s.Drake_shark_gf(int_ct,card_c:GetOwner(),card_c),int_ct-2,int_ct,function_alterf,int_dese,function_op)
					Auxiliary.XyzLevelFreeOperationAlter=Drake_shark_XyzLevelFreeOperationAlter
				else
					Drake_shark_XyzLevelFreeOperation=Auxiliary.XyzLevelFreeOperation
					function Auxiliary.XyzLevelFreeOperation(f,gf,minct,maxct)
						return  function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
									if og and not min then
										if og:GetCount()<maxct and og:GetCount()>=minct and maxct==minct+2 then
											local et=maxct-og:GetCount()
											local exg=og:Filter(Card.IsHasEffect,nil,81096431,tp)
											local ext=exg:GetClassCount(s.eftfilter,tp)
											if et==0 or 2-et==ext then
												for ttc in aux.Next(exg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											else
												local st=2-et
												Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81096431,3))
												local reg=exg:SelectSubGroup(tp,s.gcheck,false,st,st,tp)
												for ttc in aux.Next(reg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											end
										end
										local sg=Group.CreateGroup()
										local tc=og:GetFirst()
										while tc do
											local sg1=tc:GetOverlayGroup()
											sg:Merge(sg1)
											tc=og:GetNext()
										end
										Duel.SendtoGrave(sg,REASON_RULE)
										c:SetMaterial(og)
										Duel.Overlay(c,og)
									else
										local mg=e:GetLabelObject()
										if mg:GetCount()<maxct and mg:GetCount()>=minct and maxct==minct+2 then
											local et=maxct-mg:GetCount()
											local exg=mg:Filter(Card.IsHasEffect,nil,81096431,tp)
											local ext=exg:GetClassCount(s.eftfilter,tp)
											if (et==0 or 2-et==ext) and exg then
												for ttc in aux.Next(exg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											else
												local st=2-et
												Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81096431,3))
												local reg=exg:SelectSubGroup(tp,s.gcheck,false,st,st,tp)
												for ttc in aux.Next(reg) do
													local tte=ttc:IsHasEffect(81096431,tp)
													tte:UseCountLimit(tp)
												end
											end
										end
										if e:GetLabel()==1 then
											local mg2=mg:GetFirst():GetOverlayGroup()
											if mg2:GetCount()~=0 then
												Duel.Overlay(c,mg2)
											end
										else
											local sg=Group.CreateGroup()
											local tc=mg:GetFirst()
											while tc do
												local sg1=tc:GetOverlayGroup()
												sg:Merge(sg1)
												tc=mg:GetNext()
											end
											Duel.SendtoGrave(sg,REASON_RULE)
										end
										c:SetMaterial(mg)
										Duel.Overlay(c,mg)
										mg:DeleteGroup()
									end
								end
					end
					aux.AddXyzProcedureLevelFree(card_c,s.Drake_shark_f(function_f,int_lv,card_c),s.Drake_shark_gf(int_ct,card_c:GetOwner(),card_c),int_ct-2,int_ct)
					Auxiliary.XyzLevelFreeOperation=Drake_shark_XyzLevelFreeOperation
				end
			else
				if function_alterf then
					Drake_shark_AddXyzProcedure(card_c,function_f,int_lv,int_ct,function_alterf,int_dese,int_maxc,function_op)
				else
					Drake_shark_AddXyzProcedure(card_c,function_f,int_lv,int_ct,nil,nil,int_maxc,nil)
				end
			end
		end
		local rg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil,TYPE_MONSTER)
		for tc in aux.Next(rg) do
			if tc.initial_effect then
				local Traitor_initial_effect=s.initial_effect
				s.initial_effect=function() end
				tc:ReplaceEffect(id,0)
				s.initial_effect=Traitor_initial_effect
				tc.initial_effect(tc)
			end
		end
	end
	e:Reset()
end
function s.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and (c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)==RACE_MACHINE
			or c:IsPreviousLocation(LOCATION_HAND) and c:IsRace(RACE_MACHINE))
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end