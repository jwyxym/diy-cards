--隐秘的G
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--special summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(id)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		grandsaber_table={}
		grandsaber_hackspsummon=Duel.SpecialSummon
		function Duel.SpecialSummon(target,sumtype,sumplayer,tgplayer,check,limit,...)
			if Duel.IsPlayerAffectedByEffect(sumplayer,id)
				and Duel.IsPlayerCanSpecialSummonMonster(sumplayer,id) then
				if aux.GetValueType(target)=="Card" then
					if target:GetFlagEffect(id)==0
						and Duel.GetFlagEffect(1-sumplayer,id)==0 and Duel.SelectYesNo(1-sumplayer,aux.Stringid(id,0)) then
						if not target:IsType(TYPE_TOKEN) then Duel.Hint(HINT_CARD,0,target:GetOriginalCode()) end
						target:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
						Duel.ConfirmCards(1-sumplayer,target)
						Duel.Hint(HINT_SELECTMSG,1-sumplayer,HINTMSG_SPSUMMON)
						local sg=Duel.SelectMatchingCard(1-sumplayer,s.spfilter,1-sumplayer,LOCATION_HAND,0,1,1,nil)
						target=sg:GetFirst()
						target:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
						Duel.RegisterFlagEffect(1-sumplayer,id,RESET_PHASE+PHASE_END,0,1)
						if target:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(sumplayer) end
						check=true
						limit=true
						sumtype=0
					end
				elseif aux.GetValueType(target)=="Group" then
					local exg=Group.CreateGroup()
					exg=target:Filter(function(c) return c:GetFlagEffect(id)==0 end,nil)
					if #exg>0 and Duel.GetFlagEffect(1-sumplayer,id)==0 and Duel.SelectYesNo(1-sumplayer,aux.Stringid(id,0)) then
						Duel.ConfirmCards(1-sumplayer,exg)
						Duel.Hint(HINT_SELECTMSG,1-sumplayer,HINTMSG_OPERATECARD)
						local cg=exg:Select(1-sumplayer,1,1,nil)
						if not cg:GetFirst():IsType(TYPE_TOKEN) then Duel.Hint(HINT_CARD,0,cg:GetFirst():GetOriginalCode()) end
						cg:GetFirst():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
						target:Sub(cg)
						Duel.Hint(HINT_SELECTMSG,sumplayer,HINTMSG_SPSUMMON)
						local sg=Duel.SelectMatchingCard(1-sumplayer,s.spfilter,1-sumplayer,LOCATION_HAND,0,1,1,nil)
						sg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
						Duel.RegisterFlagEffect(1-sumplayer,id,RESET_PHASE+PHASE_END,0,1)
						if target:Filter(function(c) return c:IsLocation(LOCATION_HAND) end,nil) then Duel.ShuffleHand(sumplayer) end
						target:Merge(sg)
						check=true
						limit=true
						sumtype=0
					end
				end
			end
			return grandsaber_hackspsummon(target,sumtype,sumplayer,tgplayer,check,limit,...)
		end
		grandsaber_hackstep=Duel.SpecialSummonStep
		function Duel.SpecialSummonStep(target,sumtype,sumplayer,tgplayer,check,limit,...)
			if Duel.IsPlayerAffectedByEffect(sumplayer,id)
				and Duel.IsPlayerCanSpecialSummonMonster(sumplayer,id) then
				if target:GetFlagEffect(id)==0
					and Duel.GetFlagEffect(1-sumplayer,id)==0 and Duel.SelectYesNo(1-sumplayer,aux.Stringid(id,0)) then
					if not target:IsType(TYPE_TOKEN) then Duel.Hint(HINT_CARD,0,target:GetOriginalCode()) end
					target:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
					Duel.ConfirmCards(1-sumplayer,target)
					Duel.Hint(HINT_SELECTMSG,1-sumplayer,HINTMSG_SPSUMMON)
					local sg=Duel.SelectMatchingCard(1-sumplayer,s.spfilter,1-sumplayer,LOCATION_HAND,0,1,1,nil)
					sg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
					Duel.RegisterFlagEffect(1-sumplayer,id,RESET_PHASE+PHASE_END,0,1)
					if target:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(sumplayer) end
					target=sg:GetFirst()
					table.insert(grandsaber_table,target)
					check=true
					limit=true
					sumtype=0
				end
			end
			return grandsaber_hackstep(target,sumtype,sumplayer,tgplayer,check,limit,...)
		end
		grandsaber_hackcheck=Card.IsCanBeSpecialSummoned
		function Card.IsCanBeSpecialSummoned(card,effect,sumtype,sumplayer,check,limit,...)
			if card:GetFlagEffect(id)>0 then
				check=true
				limit=true
				sumtype=0
			end
			return grandsaber_hackcheck(card,effect,sumtype,sumplayer,check,limit,...)
		end
		grandsaber_Equip=Duel.Equip
		function Duel.Equip(player,c,tc,...)
			local g3=Duel.GetMatchingGroup(s.eqfilter,player,LOCATION_MZONE,LOCATION_MZONE,nil)
			if tc:GetFlagEffect(id+1)>0 then
				if #g3>0 then tc=g3:GetFirst() end
				for i,card in ipairs(grandsaber_table) do
					if card:GetFlagEffect(id)>0 then
						tc=card
						break
					end
				end
				grandsaber_table={}
				if tc and grandsaber_Equip(player,c,tc,...) then
					tc:ResetFlagEffect(id+2)
					local ee1=Effect.CreateEffect(tc)
					ee1:SetType(EFFECT_TYPE_SINGLE)
					ee1:SetCode(EFFECT_EQUIP_LIMIT)
					ee1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					ee1:SetReset(RESET_EVENT+RESETS_STANDARD)
					ee1:SetValue(s.eqlimit)
					c:RegisterEffect(ee1)
				end
				return true
			else
				return grandsaber_Equip(player,c,tc,...)
			end
		end
	end
end
function s.eqfilter(c)
	return c:GetFlagEffect(id+2)>0
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.spfilter(c)
	return c:IsOriginalCodeRule(id) or c:IsHasEffect(id)
end
function s.disop(e,tp)
	local c=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
	if c==0 then return end
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	if c>1 then
		local dis2=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,dis1)
		dis1=bit.bor(dis1,dis2)
	end
	return dis1
end